alter table public.product_flow_events
  drop constraint if exists product_flow_events_event_name_check;

alter table public.product_flow_events
  add constraint product_flow_events_event_name_check check (
    event_name in (
      'questionnaireStarted',
      'questionAnswered',
      'refinementEvaluated',
      'planGenerated',
      'recommendationViewed',
      'primaryCityExplored',
      'alternativeCityExplored',
      'comparisonOpened',
      'recommendationAccepted',
      'recommendationFeedbackPositive',
      'recommendationFeedbackNegative',
      'taskSelected',
      'taskSheetOpened',
      'taskSheetClosedIncomplete',
      'taskBlocked',
      'taskStarted',
      'taskWaiting',
      'taskResumed',
      'taskDismissed',
      'taskCompleted',
      'officialLinkOpened',
      'officialLinkReturned',
      'officialLinkFailed',
      'detailsExpanded',
      'fullPlanOpened'
    )
  );

alter table public.product_flow_events
  add column if not exists refinement_status text null check (
    refinement_status in ('ask', 'stable', 'low_gain', 'no_candidates')
  ),
  add column if not exists refinement_question_id text null check (
    refinement_question_id in ('work_arrangement', 'available_capital')
  ),
  add column if not exists refinement_gain_band text null check (
    refinement_gain_band in ('none', 'low', 'moderate', 'high')
  ),
  add column if not exists refinement_scenarios_evaluated integer null check (
    refinement_scenarios_evaluated between 0 and 20
  );

create index if not exists product_flow_events_refinement_quality_idx
  on public.product_flow_events (
    methodology_version,
    refinement_status,
    refinement_question_id,
    refinement_gain_band,
    occurred_at desc
  )
  where event_name = 'refinementEvaluated';

-- These are bounded diagnostics only. Answers, city identifiers and simulated
-- outcomes remain deliberately absent from analytics storage.
