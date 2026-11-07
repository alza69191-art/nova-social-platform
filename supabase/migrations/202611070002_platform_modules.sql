-- NOVA expansion: stories, messaging, communities, channels, marketplace and safety.
-- Apply after 202611070001_initial_social_schema.sql.

create table if not exists public.blocks (
  blocker_id uuid not null references public.profiles(id) on delete cascade,
  blocked_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
create table if not exists public.stories (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete cascade,
  media_url text not null,
  media_type text not null check (media_type in ('image','video')),
  caption text not null default '' check (char_length(caption) <= 500),
  visibility text not null default 'followers' check (visibility in ('public','followers')),
  expires_at timestamptz not null default (now() + interval '24 hours'),
  created_at timestamptz not null default now()
);
create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  created_by uuid not null references public.profiles(id) on delete cascade,
  title text,
  is_group boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.conversation_members (
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('member','admin')),
  joined_at timestamptz not null default now(),
  last_read_at timestamptz,
  primary key (conversation_id,user_id)
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text not null default '' check (char_length(body) <= 10000),
  attachment_url text,
  attachment_type text check (attachment_type is null or attachment_type in ('image','video','file')),
  edited_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  check (char_length(trim(body)) > 0 or attachment_url is not null)
);
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 2 and 80),
  slug text unique,
  description text not null default '' check (char_length(description) <= 1000),
  visibility text not null default 'public' check (visibility in ('public','private')),
  created_at timestamptz not null default now()
);
create table if not exists public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','moderator','member')),
  status text not null default 'active' check (status in ('pending','active','banned')),
  joined_at timestamptz not null default now(),
  primary key (group_id,user_id)
);
create table if not exists public.channels (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 2 and 100),
  slug text unique,
  description text not null default '' check (char_length(description) <= 2000),
  avatar_url text,
  created_at timestamptz not null default now()
);
create table if not exists public.channel_subscriptions (
  channel_id uuid not null references public.channels(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (channel_id,user_id)
);
create table if not exists public.videos (
  id uuid primary key default gen_random_uuid(),
  channel_id uuid not null references public.channels(id) on delete cascade,
  owner_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 1 and 180),
  description text not null default '' check (char_length(description) <= 5000),
  video_url text not null,
  thumbnail_url text,
  visibility text not null default 'public' check (visibility in ('public','unlisted','private')),
  status text not null default 'processing' check (status in ('processing','published','rejected')),
  created_at timestamptz not null default now()
);
create table if not exists public.listings (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (char_length(trim(title)) between 2 and 160),
  description text not null default '' check (char_length(description) <= 5000),
  category text not null default 'other',
  price numeric(12,2) not null check (price >= 0),
  currency text not null default 'USD' check (currency ~ '^[A-Z]{3}$'),
  listing_type text not null default 'product' check (listing_type in ('product','digital','service')),
  status text not null default 'draft' check (status in ('draft','active','sold','removed')),
  created_at timestamptz not null default now()
);
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  kind text not null check (kind in ('follow','reaction','comment','message','group','system')),
  entity_id uuid,
  body text not null default '' check (char_length(body) <= 500),
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles(id) on delete cascade,
  target_type text not null check (target_type in ('profile','post','comment','message','group','video','listing')),
  target_id uuid not null,
  reason text not null check (char_length(trim(reason)) between 3 and 1000),
  status text not null default 'open' check (status in ('open','reviewing','actioned','dismissed')),
  created_at timestamptz not null default now()
);

create index if not exists stories_author_expiry_idx on public.stories(author_id,expires_at desc);
create index if not exists messages_conversation_created_idx on public.messages(conversation_id,created_at desc);
create index if not exists notifications_recipient_created_idx on public.notifications(recipient_id,created_at desc);
create index if not exists listings_active_created_idx on public.listings(created_at desc) where status='active';
create index if not exists videos_channel_created_idx on public.videos(channel_id,created_at desc);

alter table public.blocks enable row level security;
alter table public.stories enable row level security;
alter table public.conversations enable row level security;
alter table public.conversation_members enable row level security;
alter table public.messages enable row level security;
alter table public.groups enable row level security;
alter table public.group_members enable row level security;
alter table public.channels enable row level security;
alter table public.channel_subscriptions enable row level security;
alter table public.videos enable row level security;
alter table public.listings enable row level security;
alter table public.notifications enable row level security;
alter table public.reports enable row level security;

create policy "Block lists visible to blocker" on public.blocks for select to authenticated using (blocker_id = (select auth.uid()));
create policy "Users block accounts" on public.blocks for insert to authenticated with check (blocker_id = (select auth.uid()));
create policy "Users unblock accounts" on public.blocks for delete to authenticated using (blocker_id = (select auth.uid()));

create policy "Stories visible to permitted viewers" on public.stories for select to authenticated using (
  author_id = (select auth.uid()) or (expires_at > now() and (
    visibility = 'public' or exists (select 1 from public.follows f where f.follower_id = (select auth.uid()) and f.following_id = stories.author_id and f.status = 'accepted')
  ))
);
create policy "Users publish stories" on public.stories for insert to authenticated with check (author_id = (select auth.uid()));
create policy "Authors delete stories" on public.stories for delete to authenticated using (author_id = (select auth.uid()));

create policy "Conversation participants can view" on public.conversations for select to authenticated using (
  exists (select 1 from public.conversation_members m where m.conversation_id = id and m.user_id = (select auth.uid()))
);
create policy "Users create conversations" on public.conversations for insert to authenticated with check (created_by = (select auth.uid()));
create policy "Members can view membership" on public.conversation_members for select to authenticated using (
  user_id = (select auth.uid()) or exists (select 1 from public.conversation_members mine where mine.conversation_id = conversation_id and mine.user_id = (select auth.uid()))
);
create policy "Users add themselves to conversations" on public.conversation_members for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Users leave conversations" on public.conversation_members for delete to authenticated using (user_id = (select auth.uid()));
create policy "Members read messages" on public.messages for select to authenticated using (
  exists (select 1 from public.conversation_members m where m.conversation_id = messages.conversation_id and m.user_id = (select auth.uid()))
);
create policy "Members send messages" on public.messages for insert to authenticated with check (
  sender_id = (select auth.uid()) and exists (select 1 from public.conversation_members m where m.conversation_id = messages.conversation_id and m.user_id = (select auth.uid()))
);
create policy "Senders soft delete own messages" on public.messages for update to authenticated using (sender_id = (select auth.uid())) with check (sender_id = (select auth.uid()));

create policy "Public groups and memberships visible" on public.groups for select to authenticated using (
  visibility = 'public' or owner_id = (select auth.uid()) or exists (select 1 from public.group_members gm where gm.group_id = id and gm.user_id = (select auth.uid()) and gm.status = 'active')
);
create policy "Users create groups" on public.groups for insert to authenticated with check (owner_id = (select auth.uid()));
create policy "Owners update groups" on public.groups for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "Group members view membership" on public.group_members for select to authenticated using (
  user_id = (select auth.uid()) or exists (select 1 from public.groups g where g.id = group_id and g.visibility = 'public')
);
create policy "Users request group membership" on public.group_members for insert to authenticated with check (user_id = (select auth.uid()) and role = 'member');
create policy "Users leave groups" on public.group_members for delete to authenticated using (user_id = (select auth.uid()));

create policy "Channels are discoverable" on public.channels for select to authenticated using (true);
create policy "Owners create channels" on public.channels for insert to authenticated with check (owner_id = (select auth.uid()));
create policy "Owners update channels" on public.channels for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));
create policy "Subscriptions visible to owner" on public.channel_subscriptions for select to authenticated using (user_id = (select auth.uid()));
create policy "Users subscribe to channels" on public.channel_subscriptions for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Users unsubscribe" on public.channel_subscriptions for delete to authenticated using (user_id = (select auth.uid()));
create policy "Published videos are discoverable" on public.videos for select to authenticated using (
  (status = 'published' and visibility in ('public','unlisted')) or owner_id = (select auth.uid())
);
create policy "Channel owners upload video metadata" on public.videos for insert to authenticated with check (
  owner_id = (select auth.uid()) and exists (select 1 from public.channels c where c.id = channel_id and c.owner_id = (select auth.uid()))
);
create policy "Video owners update metadata" on public.videos for update to authenticated using (owner_id = (select auth.uid())) with check (owner_id = (select auth.uid()));

create policy "Active listings visible" on public.listings for select to authenticated using (status = 'active' or seller_id = (select auth.uid()));
create policy "Sellers create listings" on public.listings for insert to authenticated with check (seller_id = (select auth.uid()));
create policy "Sellers manage listings" on public.listings for update to authenticated using (seller_id = (select auth.uid())) with check (seller_id = (select auth.uid()));
create policy "Sellers remove listings" on public.listings for delete to authenticated using (seller_id = (select auth.uid()));

create policy "Users see their notifications" on public.notifications for select to authenticated using (recipient_id = (select auth.uid()));
create policy "Users mark notifications read" on public.notifications for update to authenticated using (recipient_id = (select auth.uid())) with check (recipient_id = (select auth.uid()));
create policy "Users submit reports" on public.reports for insert to authenticated with check (reporter_id = (select auth.uid()));
create policy "Users see their reports" on public.reports for select to authenticated using (reporter_id = (select auth.uid()));
