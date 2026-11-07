-- NOVA initial social graph and publishing schema.
-- Apply this migration in the Supabase SQL Editor or through Supabase CLI.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  display_name text not null default '',
  bio text not null default '',
  avatar_url text,
  is_private boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_username_format check (username is null or username ~ '^[a-zA-Z0-9_]{3,24}$'),
  constraint profiles_bio_length check (char_length(bio) <= 280)
);

create table if not exists public.follows (
  follower_id uuid not null references public.profiles(id) on delete cascade,
  following_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'accepted' check (status in ('pending', 'accepted')),
  created_at timestamptz not null default now(),
  primary key (follower_id, following_id),
  constraint follows_no_self check (follower_id <> following_id)
);

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  content text not null default '',
  media_url text,
  media_type text check (media_type is null or media_type in ('image', 'video')),
  visibility text not null default 'public' check (visibility in ('public', 'followers', 'private')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint posts_content_length check (char_length(content) <= 5000),
  constraint posts_not_empty check (char_length(trim(content)) > 0 or media_url is not null)
);

create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.posts(id) on delete cascade,
  author_id uuid not null references public.profiles(id) on delete cascade,
  parent_id uuid references public.comments(id) on delete cascade,
  content text not null check (char_length(trim(content)) between 1 and 2000),
  created_at timestamptz not null default now()
);

create table if not exists public.reactions (
  post_id uuid not null references public.posts(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  reaction text not null default 'like' check (reaction in ('like', 'love', 'celebrate', 'support')),
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

create index if not exists posts_author_created_idx on public.posts (author_id, created_at desc);
create index if not exists posts_feed_created_idx on public.posts (created_at desc) where visibility = 'public';
create index if not exists comments_post_created_idx on public.comments (post_id, created_at);
create index if not exists follows_following_status_idx on public.follows (following_id, status);
create index if not exists follows_follower_status_idx on public.follows (follower_id, status);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', '')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute procedure public.set_updated_at();

drop trigger if exists posts_set_updated_at on public.posts;
create trigger posts_set_updated_at before update on public.posts
for each row execute procedure public.set_updated_at();

alter table public.profiles enable row level security;
alter table public.follows enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.reactions enable row level security;

-- Profiles: public profiles are discoverable; private profiles are visible to their owner and accepted followers.
drop policy if exists "Profiles are visible according to privacy" on public.profiles;
create policy "Profiles are visible according to privacy"
on public.profiles for select to authenticated
using (
  id = (select auth.uid())
  or is_private = false
  or exists (
    select 1 from public.follows f
    where f.follower_id = (select auth.uid())
      and f.following_id = profiles.id
      and f.status = 'accepted'
  )
);

drop policy if exists "Users create their own profile" on public.profiles;
create policy "Users create their own profile"
on public.profiles for insert to authenticated
with check (id = (select auth.uid()));

drop policy if exists "Users update their own profile" on public.profiles;
create policy "Users update their own profile"
on public.profiles for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

-- Follows: users can create/remove their own outgoing follows; only the target can approve a request.
drop policy if exists "Users can view related follows" on public.follows;
create policy "Users can view related follows"
on public.follows for select to authenticated
using (
  follower_id = (select auth.uid())
  or following_id = (select auth.uid())
  or status = 'accepted'
);

drop policy if exists "Users can follow as themselves" on public.follows;
create policy "Users can follow as themselves"
on public.follows for insert to authenticated
with check (
  follower_id = (select auth.uid())
  and follower_id <> following_id
  and (
    status = 'pending'
    or (
      status = 'accepted'
      and exists (
        select 1 from public.profiles p
        where p.id = following_id and p.is_private = false
      )
    )
  )
);

drop policy if exists "Target can approve follow requests" on public.follows;
create policy "Target can approve follow requests"
on public.follows for update to authenticated
using (following_id = (select auth.uid()) and status = 'pending')
with check (following_id = (select auth.uid()) and status = 'accepted');

drop policy if exists "Follower can unfollow" on public.follows;
create policy "Follower can unfollow"
on public.follows for delete to authenticated
using (follower_id = (select auth.uid()) or following_id = (select auth.uid()));

-- Posts: respect post visibility and private-profile follow relationships.
drop policy if exists "Posts visible to permitted viewers" on public.posts;
create policy "Posts visible to permitted viewers"
on public.posts for select to authenticated
using (
  author_id = (select auth.uid())
  or (
    visibility = 'public'
    and exists (select 1 from public.profiles p where p.id = author_id and p.is_private = false)
  )
  or (
    visibility = 'followers'
    and exists (
      select 1 from public.follows f
      where f.follower_id = (select auth.uid())
        and f.following_id = posts.author_id
        and f.status = 'accepted'
    )
  )
  or (
    visibility = 'public'
    and exists (
      select 1 from public.follows f
      where f.follower_id = (select auth.uid())
        and f.following_id = posts.author_id
        and f.status = 'accepted'
    )
  )
);

drop policy if exists "Users publish as themselves" on public.posts;
create policy "Users publish as themselves"
on public.posts for insert to authenticated
with check (author_id = (select auth.uid()));

drop policy if exists "Authors update their posts" on public.posts;
create policy "Authors update their posts"
on public.posts for update to authenticated
using (author_id = (select auth.uid()))
with check (author_id = (select auth.uid()));

drop policy if exists "Authors delete their posts" on public.posts;
create policy "Authors delete their posts"
on public.posts for delete to authenticated
using (author_id = (select auth.uid()));

-- Comments can be read only when the parent post is visible.
drop policy if exists "Comments visible with their post" on public.comments;
create policy "Comments visible with their post"
on public.comments for select to authenticated
using (
  exists (
    select 1 from public.posts p
    where p.id = comments.post_id
      and (
        p.author_id = (select auth.uid())
        or (p.visibility = 'public' and exists (
          select 1 from public.profiles pr where pr.id = p.author_id and pr.is_private = false
        ))
        or (p.visibility = 'followers' and exists (
          select 1 from public.follows f where f.follower_id = (select auth.uid())
            and f.following_id = p.author_id and f.status = 'accepted'
        ))
        or exists (
          select 1 from public.follows f where f.follower_id = (select auth.uid())
            and f.following_id = p.author_id and f.status = 'accepted'
        )
      )
  )
);

drop policy if exists "Users comment as themselves" on public.comments;
create policy "Users comment as themselves"
on public.comments for insert to authenticated
with check (
  author_id = (select auth.uid())
  and exists (
    select 1 from public.posts p
    where p.id = comments.post_id
      and (
        p.author_id = (select auth.uid())
        or p.visibility = 'public'
        or exists (
          select 1 from public.follows f where f.follower_id = (select auth.uid())
            and f.following_id = p.author_id and f.status = 'accepted'
        )
      )
  )
);

drop policy if exists "Authors delete their comments" on public.comments;
create policy "Authors delete their comments"
on public.comments for delete to authenticated
using (author_id = (select auth.uid()));

-- Reactions are available only for posts visible to the reacting user.
drop policy if exists "Reactions visible with their post" on public.reactions;
create policy "Reactions visible with their post"
on public.reactions for select to authenticated
using (
  exists (
    select 1 from public.posts p
    where p.id = reactions.post_id
      and (
        p.author_id = (select auth.uid())
        or p.visibility = 'public'
        or exists (
          select 1 from public.follows f where f.follower_id = (select auth.uid())
            and f.following_id = p.author_id and f.status = 'accepted'
        )
      )
  )
);

drop policy if exists "Users react as themselves" on public.reactions;
create policy "Users react as themselves"
on public.reactions for insert to authenticated
with check (
  user_id = (select auth.uid())
  and exists (
    select 1 from public.posts p
    where p.id = reactions.post_id
      and (
        p.author_id = (select auth.uid())
        or p.visibility = 'public'
        or exists (
          select 1 from public.follows f where f.follower_id = (select auth.uid())
            and f.following_id = p.author_id and f.status = 'accepted'
        )
      )
  )
);

drop policy if exists "Users remove their reactions" on public.reactions;
create policy "Users remove their reactions"
on public.reactions for delete to authenticated
using (user_id = (select auth.uid()));
