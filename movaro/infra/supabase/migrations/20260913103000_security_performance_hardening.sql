alter function public.set_updated_at() set search_path = '';
alter function public.sync_plan_progress_owner() set search_path = '';
alter function public.set_city_insights_cache_updated_at() set search_path = '';

revoke execute on function public.rls_auto_enable() from public, anon, authenticated;

create index if not exists assistant_message_feedback_owner_idx
  on public.assistant_message_feedback (owner_user_id);

drop policy if exists "Users manage own migration plans" on public.migration_plans;
create policy "Users manage own migration plans"
on public.migration_plans
for all
using (owner_user_id = (select auth.uid()))
with check (owner_user_id = (select auth.uid()));

drop policy if exists "Users manage own migration plan progress" on public.migration_plan_progress;
create policy "Users manage own migration plan progress"
on public.migration_plan_progress
for all
using (owner_user_id = (select auth.uid()))
with check (owner_user_id = (select auth.uid()));

drop policy if exists "Users manage own chat sessions" on public.assistant_chat_sessions;
create policy "Users manage own chat sessions"
on public.assistant_chat_sessions
for all
using (owner_user_id = (select auth.uid()))
with check (owner_user_id = (select auth.uid()));

drop policy if exists "Users manage own chat messages" on public.assistant_chat_messages;
create policy "Users manage own chat messages"
on public.assistant_chat_messages
for all
using (owner_user_id = (select auth.uid()))
with check (owner_user_id = (select auth.uid()));

drop policy if exists "Users manage own chat feedback" on public.assistant_message_feedback;
create policy "Users manage own chat feedback"
on public.assistant_message_feedback
for all
using (owner_user_id = (select auth.uid()))
with check (owner_user_id = (select auth.uid()));

drop policy if exists "Service role manages assistant language rules" on public.assistant_language_rules;
create policy "Service role manages assistant language rules"
on public.assistant_language_rules
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "Service role manages assistant faq entries" on public.assistant_faq_entries;
create policy "Service role manages assistant faq entries"
on public.assistant_faq_entries
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "Service role manages assistant faq keywords" on public.assistant_faq_keywords;
create policy "Service role manages assistant faq keywords"
on public.assistant_faq_keywords
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "Service role manages assistant document entries" on public.assistant_document_entries;
create policy "Service role manages assistant document entries"
on public.assistant_document_entries
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "Service role manages assistant document keywords" on public.assistant_document_keywords;
create policy "Service role manages assistant document keywords"
on public.assistant_document_keywords
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "Service role manages assistant quick prompt templates" on public.assistant_quick_prompt_templates;
create policy "Service role manages assistant quick prompt templates"
on public.assistant_quick_prompt_templates
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "Service role manages assistant guide answers" on public.assistant_guide_answers;
create policy "Service role manages assistant guide answers"
on public.assistant_guide_answers
for all
using ((select auth.role()) = 'service_role')
with check ((select auth.role()) = 'service_role');

drop policy if exists "app_state_snapshots_select_own" on public.app_state_snapshots;
create policy "app_state_snapshots_select_own"
on public.app_state_snapshots
for select
to authenticated, anon
using ((select auth.uid()) = user_id);

drop policy if exists "app_state_snapshots_insert_own" on public.app_state_snapshots;
create policy "app_state_snapshots_insert_own"
on public.app_state_snapshots
for insert
to authenticated, anon
with check ((select auth.uid()) = user_id);

drop policy if exists "app_state_snapshots_update_own" on public.app_state_snapshots;
create policy "app_state_snapshots_update_own"
on public.app_state_snapshots
for update
to authenticated, anon
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "app_state_snapshots_delete_own" on public.app_state_snapshots;
create policy "app_state_snapshots_delete_own"
on public.app_state_snapshots
for delete
to authenticated, anon
using ((select auth.uid()) = user_id);
