-- NOVA RLS hardening: avoid recursive membership policies and prevent unauthorized joins.
-- Apply after 202611070002_platform_modules.sql.

create or replace function public.is_conversation_member(_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.conversation_members m
    where m.conversation_id = _conversation_id
      and m.user_id = (select auth.uid())
  );
$$;

create or replace function public.is_conversation_creator(_conversation_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.conversations c
    where c.id = _conversation_id
      and c.created_by = (select auth.uid())
  );
$$;

create or replace function public.is_group_owner(_group_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.groups g
    where g.id = _group_id
      and g.owner_id = (select auth.uid())
  );
$$;

create or replace function public.can_join_group(_group_id uuid, _status text)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.groups g
    where g.id = _group_id
      and (
        (g.visibility = 'public' and _status = 'active')
        or (g.visibility = 'private' and _status = 'pending')
      )
  );
$$;

revoke all on function public.is_conversation_member(uuid) from public;
revoke all on function public.is_conversation_creator(uuid) from public;
revoke all on function public.is_group_owner(uuid) from public;
revoke all on function public.can_join_group(uuid,text) from public;
grant execute on function public.is_conversation_member(uuid) to authenticated;
grant execute on function public.is_conversation_creator(uuid) to authenticated;
grant execute on function public.is_group_owner(uuid) to authenticated;
grant execute on function public.can_join_group(uuid,text) to authenticated;

drop policy if exists "Conversation participants can view" on public.conversations;
create policy "Conversation participants can view"
on public.conversations for select to authenticated
using (public.is_conversation_member(id));

drop policy if exists "Members can view membership" on public.conversation_members;
create policy "Members can view membership"
on public.conversation_members for select to authenticated
using (user_id = (select auth.uid()) or public.is_conversation_member(conversation_id));

drop policy if exists "Users add themselves to conversations" on public.conversation_members;
create policy "Conversation creators add themselves"
on public.conversation_members for insert to authenticated
with check (user_id = (select auth.uid()) and public.is_conversation_creator(conversation_id));

drop policy if exists "Users request group membership" on public.group_members;
create policy "Users join public groups or request private groups"
on public.group_members for insert to authenticated
with check (
  user_id = (select auth.uid())
  and role = 'member'
  and public.can_join_group(group_id,status)
);

create policy "Group owners approve membership"
on public.group_members for update to authenticated
using (public.is_group_owner(group_id) and status = 'pending')
with check (public.is_group_owner(group_id) and status = 'active' and role = 'member');

drop policy if exists "Senders soft delete own messages" on public.messages;
create policy "Senders update own messages within their conversations"
on public.messages for update to authenticated
using (
  sender_id = (select auth.uid())
  and public.is_conversation_member(conversation_id)
)
with check (
  sender_id = (select auth.uid())
  and public.is_conversation_member(conversation_id)
);

drop policy if exists "Group members view membership" on public.group_members;
create policy "Users view their own group membership"
on public.group_members for select to authenticated
using (user_id = (select auth.uid()));
