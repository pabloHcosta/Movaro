# Build My Plan V2

## Objective

Redesign the `Build My Plan` flow to feel faster, more useful, and more personalized for the initial migration journey from Argentina to Brazil.

The flow should:

- collect only the minimum information needed to recommend a starting direction
- avoid bureaucratic or form-heavy behavior
- work as a mobile-first wizard with one decision per screen
- return a practical result with:
  - an archetype
  - a ranked top 3 of cities
  - 3 immediate next steps

This spec consolidates the product brief into an implementation target for the Flutter app.

## Product Scope

Current focus:

- origin: Argentina
- destination: Brazil
- audience: people in the early stage of deciding or planning the move

The result is not legal advice and should be positioned as a practical starting point.

## Questionnaire Model

### Phase 1

Implement only the `lean` variant.

Flow:

1. `intent`
2. `timeline`
3. `priorities`
4. refine prompt
5. optional `constraints`
6. result

Rules:

- 3 core questions
- optional refine prompt after the core flow
- if accepted, show 1 extra optional question
- max displayed questions: 4
- no personal data collection
- no free text
- mobile-first, tap-first

### Deferred Phase 2

- add `strategic` variant
- add `funding`
- add analytics depth and backend parity
- add stronger persistence / resume behavior

## Question Definitions

### `intent`

- type: `single_card`
- required: yes
- options:
  - `find_job_br`
  - `remote_income`
  - `study`
  - `family_partner`
  - `fresh_start`
  - `explore_unsure`

### `timeline`

- type: `single_chip`
- required: yes
- options:
  - `just_exploring`
  - `in_0_3m`
  - `in_3_6m`
  - `in_6_12m`
  - `in_12m_plus`
  - `depends`

### `priorities`

- type: `multi_chip`
- required: yes
- max selections: `2`
- options:
  - `low_cost`
  - `job_opportunities`
  - `safety`
  - `warm_climate_beach`
  - `transit_infra`
  - `nature`
  - `university`
  - `community`
  - `close_to_argentina`
  - `balanced_unsure`

Rules:

- `balanced_unsure` behaves as an exclusive option
- when selected, block all other options

### `constraints`

- type: `multi_chip`
- required: no
- max selections: `2`
- options:
  - `prefer_south`
  - `need_big_city`
  - `prefer_mid_city`
  - `want_coast`
  - `prefer_cooler`
  - `need_transit`
  - `avoid_expensive`
  - `no_constraints`

Rules:

- `no_constraints` behaves as an exclusive option
- question appears only if user accepts refine
- question can be skipped

## UX Rules

- one screen per question
- progress indicator always visible on core questions
- single-select answers auto-advance after short delay
- multi-select answers require explicit continue
- keep support text short
- avoid large explanatory paragraphs
- refine prompt is a separate lightweight screen, not counted as a core question

## Result Model

The generated plan should include:

- `archetypeKey`
- `confidence`
- `candidateCities` with top 3 ranked cities
- `recommendedCity` as rank #1
- `cityRecommendationReasons` for the recommended city
- `steps` with exactly 3 initial actions
- answer echo for summary usage

## Archetypes

Base mapping from `intent`:

- `find_job_br` -> `job_hunter`
- `remote_income` -> `remote_worker`
- `study` -> `student`
- `family_partner` -> `family_move`
- `fresh_start` -> `fresh_start`
- `explore_unsure` -> `explorer`

## Scoring Model

### City dimensions

The current city catalog does not expose normalized dimensions directly.

Phase 1 should derive a normalized profile from existing city data:

- `affordability`
- `job_market`
- `safety`
- `climate_warmth`
- `transit_infra`
- `nature`
- `university`
- `community`
- `proximity_argentina`

These dimensions should be computed locally from the existing `City` entity and lightweight geographic heuristics.

### Priority boosts

- `low_cost` -> affordability
- `job_opportunities` -> job_market
- `safety` -> safety
- `warm_climate_beach` (chave legada exibida como litoral/praia) -> nature;
  clima só deve voltar ao score quando houver normais comparáveis
- `transit_infra` -> transit_infra
- `nature` -> nature
- `university` -> university
- `community` -> community
- `close_to_argentina` -> proximity_argentina
- `balanced_unsure` -> balanced preset + lower confidence

### Constraints

Use soft penalties, not hard filters.

Examples:

- `want_coast`: penalize inland cities
- `prefer_south`: penalize non-south cities
- `need_big_city`: penalize non-big cities
- `prefer_mid_city`: penalize big cities
- `prefer_cooler`: penalize warmer cities
- `need_transit`: scale by transit dimension
- `avoid_expensive`: scale by affordability

### Confidence

Confidence should combine:

- completeness of answers
- amount of unsure selections
- score separation between top 1 and top 2
- constraint conflicts

## Checklist Rules

Always return exactly 3 steps.

One step must always cover CPF.

Suggested structure:

1. choose one base city / first practical commitment
2. understand the residence path at a high level
3. start CPF guidance

Timeline should adjust the wording:

- exploring: more discovery-oriented
- 0-3 months: more execution-oriented
- 3-12 months: balanced

## Required Flutter Changes

### 1. Domain model changes

Current limitations:

- `Answer` only supports one string value
- `Question` does not describe caps, optional state, or UI behavior
- `MigrationPlan` does not expose archetype or confidence

Required changes:

- update `Answer` to support `List<String>`
- update `Question` to support:
  - `selectionType`
  - `maxSelections`
  - `isOptional`
- extend `MigrationPlan` with:
  - `archetypeKey`
  - `confidence`
  - optional summary values for selected priorities and constraints

### 2. Data / config changes

Replace the hard-coded current 3-question repository with configurable question definitions for:

- `intent`
- `timeline`
- `priorities`
- `constraints`

### 3. Controller changes

Current controller assumes:

- only linear questions
- only one selected answer per question
- last question directly generates the result

Required changes:

- support single and multi answers
- support refine prompt state
- support optional extra question
- expose progress for dynamic flow
- keep journey origin and destination synced

### 4. UI changes

Current UI only supports a list of radio-like cards.

Required changes:

- card grid for `single_card`
- chip selector for `single_chip`
- multi-chip selector with cap handling
- refine prompt screen
- inline validation / helper text

### 5. Scoring engine changes

Replace the current city recommendation heuristic based on:

- `goal`
- `portuguese_familiarity`
- `timeline`

with a new scoring engine based on:

- archetype
- priorities
- optional constraints
- lightweight normalized city dimensions

### 6. Result changes

Current result screen already supports:

- one recommended city
- candidate city list
- recommendation reasons

Phase 1 should keep this structure but update the data source so the result reflects:

- top 3 ranked cities
- new reasons generated from selected priorities
- new 3-step checklist

## Current Code Mapping

Main files impacted:

- `apps/app/lib/features/migration_questionnaire/domain/entities/answer.dart`
- `apps/app/lib/features/migration_questionnaire/domain/entities/question.dart`
- `apps/app/lib/features/migration_questionnaire/domain/entities/migration_plan.dart`
- `apps/app/lib/features/migration_questionnaire/data/models/question_model.dart`
- `apps/app/lib/features/migration_questionnaire/data/models/migration_plan_model.dart`
- `apps/app/lib/features/migration_questionnaire/data/repositories/question_repository_impl.dart`
- `apps/app/lib/features/migration_questionnaire/application/migration_questionnaire_controller.dart`
- `apps/app/lib/features/migration_questionnaire/application/services/migration_plan_generator.dart`
- `apps/app/lib/features/migration_questionnaire/presentation/pages/question_page.dart`
- `apps/app/lib/app/localization/app_localization.dart`
- `apps/app/lib/app/localization/arb/*.arb`

Likely new files:

- questionnaire config file
- scoring engine file
- chip selector widget
- refine prompt widget or page

## Implementation Plan

### Phase 1

- ship lean questionnaire in Flutter
- preserve route names and general flow
- keep scoring on-device
- reuse current result page as much as possible

### Phase 2

- strategic variant
- analytics instrumentation
- optional backend parity endpoint
- stronger recommendation explanation
- optional post-result save/account prompts

## Non-goals for Phase 1

- backend API rewrite
- legal workflow depth
- personal document upload
- account creation requirement
- deep residency branching
- long-form questionnaire
