alter table public.product_flow_events
  drop constraint if exists product_flow_events_event_name_check;

alter table public.product_flow_events
  add constraint product_flow_events_event_name_check check (
    event_name in (
      'questionnaireStarted',
      'questionAnswered',
      'planGenerated',
      'recommendationViewed',
      'primaryCityExplored',
      'alternativeCityExplored',
      'comparisonOpened',
      'recommendationAccepted',
      'recommendationFeedbackPositive',
      'recommendationFeedbackNegative',
      'taskSelected',
      'taskStarted',
      'taskWaiting',
      'taskResumed',
      'taskCompleted',
      'fullPlanOpened'
    )
  );

alter table public.product_flow_events
  add column if not exists methodology_version text null,
  add column if not exists stability_band text null check (
    stability_band in ('robust', 'moderate', 'sensitive', 'insufficient_data')
  ),
  add column if not exists coverage_band text null check (
    coverage_band in ('broad', 'partial', 'limited')
  ),
  add column if not exists rank_position integer null check (
    rank_position between 1 and 3
  );

create index if not exists product_flow_events_recommendation_quality_idx
  on public.product_flow_events (
    methodology_version,
    stability_band,
    coverage_band,
    event_name,
    occurred_at desc
  )
  where methodology_version is not null;

-- Deliberately absent: city id, recommendation id, answers, budget and
-- coordinates. P2 measures aggregate quality bands without retaining the
-- user's migration profile.
