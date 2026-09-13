-- These tables were provisioned for a normalized persistence model that was
-- never connected to the application. Migration state is synchronized through
-- app_state_snapshots, and chat history remains local to the device.
drop table if exists public.assistant_message_feedback;
drop table if exists public.assistant_chat_messages;
drop table if exists public.assistant_chat_sessions;
drop table if exists public.migration_plan_progress;
drop table if exists public.migration_plans;

drop function if exists public.sync_plan_progress_owner();
