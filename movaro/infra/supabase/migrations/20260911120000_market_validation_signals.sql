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
      'fullPlanOpened',
      'pilotCheckInShown',
      'pilotCheckInDismissed',
      'pilotCheckInSubmitted'
    )
  );

alter table public.product_flow_events
  add column if not exists validation_clarity_band text null check (
    validation_clarity_band in ('clear', 'partial', 'unclear')
  ),
  add column if not exists validation_progress_band text null check (
    validation_progress_band in ('completed', 'blocked', 'notStarted')
  ),
  add column if not exists validation_value_band text null check (
    validation_value_band in ('high', 'moderate', 'low')
  ),
  add column if not exists validation_phase_band text null check (
    validation_phase_band in (
      'preparation',
      'housing',
      'documents',
      'work',
      'arrival'
    )
  );

create index if not exists product_flow_events_market_validation_idx
  on public.product_flow_events (
    event_name,
    validation_phase_band,
    validation_clarity_band,
    validation_progress_band,
    validation_value_band,
    occurred_at desc
  )
  where event_name in (
    'pilotCheckInShown',
    'pilotCheckInDismissed',
    'pilotCheckInSubmitted'
  );

-- The pilot stores only bounded response categories and a broad journey phase.
-- Task identifiers, city,
-- free text, documents, questionnaire answers and financial values stay out.
