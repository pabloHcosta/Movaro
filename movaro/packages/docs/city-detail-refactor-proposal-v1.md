# City Detail Refactor Proposal V1

## Objective

Transform `CityDetailPage` into a layered, decision-oriented experience that:

- reduces cognitive load without removing relevant information
- keeps the first screen useful in a few seconds
- preserves trust through clearer evidence and source access
- supports mobile-first reading and comparison behavior
- reuses the current data model and controller architecture as much as possible

This proposal converts the findings from [city-detail-ux-review-v2.md](/Users/pablocosta/Developer/Movaro/movaro/packages/docs/city-detail-ux-review-v2.md) into an implementation target.

## Product Goal

The page should answer 3 user questions in order:

1. vale seguir considerando esta cidade?
2. por que ela faz ou nao faz sentido para mim?
3. qual evidencia sustenta essa leitura?

Today those answers exist, but they are spread across a long linear page. The refactor should make those answers progressively available in layers.

## Core UX Principles

- first fold answers the decision question
- structure stays visible during scrolling
- each section has one primary job
- narrative supports evidence, not the opposite
- secondary evidence stays accessible, but does not compete with the main decision flow
- mobile users should not need long sequential reading to understand the page

## Proposed Information Architecture

Replace the current long page with 5 primary areas:

1. Overview
2. Custo e chegada
3. Vida na pratica
4. Comparacao
5. Evidencias

### Area responsibilities

#### 1. Overview

Purpose:

- answer whether the city is a strong, fair, or risky option
- show the key reasons and the main caution
- offer the next action immediately

Contains:

- compact hero
- decision summary
- highlights strip
- top criteria snapshot
- primary CTA row

#### 2. Custo e chegada

Purpose:

- answer whether the user can land and stabilize in the city

Contains:

- arrival viability
- cost of living summary
- flight burden when available

#### 3. Vida na pratica

Purpose:

- explain what daily life tends to feel like

Contains:

- city narrative
- climate summary
- people like you
- neighborhood guidance

#### 4. Comparacao

Purpose:

- help the user avoid isolated decision-making

Contains:

- strengths
- comparison summary
- compare CTA

#### 5. Evidencias

Purpose:

- preserve transparency and deeper context without crowding the main flow

Contains:

- seasonality
- map
- public opinion
- detailed analysis
- sources

## Proposed Navigation Model

### Primary navigation

Use a persistent section navigation bar after the hero.

Recommended Flutter structure:

- `NestedScrollView`
- `SliverAppBar` for the existing glass header / hero behavior
- sticky `TabBar` or segmented bar for the 5 primary areas
- each area rendered as a vertically scrollable section within a single coordinated scroll

Recommended labels:

- Overview
- Custo
- Vida
- Comparar
- Evidencias

Why this model:

- preserves direct access
- keeps the page feeling like one screen
- avoids forcing the user into horizontal chips with low discoverability
- works better than 15+ quick links

### Secondary navigation inside areas

Do not expose all subsections in global navigation.

Instead:

- use internal cards and mini-links
- use `See details` only within a clearly named context
- use accordions only inside `Evidencias`

### What gets removed

- current `Quick access` chip rail
- current single generic `Ver mais sobre {cidade}`

### What replaces the generic secondary disclosure

Inside `Evidencias`, use explicit expandable groups:

- Sazonalidade
- Mapa e localizacao
- Opiniao publica
- Analise detalhada
- Fontes e metodologia

This preserves progressive disclosure while improving information scent.

## Proposed Screen Structure

## 1. Hero

Keep:

- city name
- state
- favorite action
- weather / lifestyle support

Change:

- reduce visual dominance
- hero should not consume too much vertical space on mobile
- keep decorative image but shrink the reading burden before decision content

Target:

- max height should feel closer to contextual banner than immersive landing

## 2. First Fold

This becomes the most important change.

### New composition

#### A. Decision Summary Card

Single card with:

- verdict label
- one-sentence interpretation
- one primary caution
- one next step

Rules:

- maximum 1 paragraph
- maximum 1 caution item visible by default
- avoid stacking multiple warning cards in the first fold

#### B. Highlights Strip

Show 4 or 5 concise facts, for example:

- custo mensal estimado
- pressao de chegada
- seguranca
- melhor sinal da cidade
- proximo passo recomendado

Each fact should be scannable in 1 glance:

- short label
- short value
- optional tone color

#### C. Criteria Snapshot

Keep the existing category logic, but make it a compact comparative surface:

- housing
- safety
- work
- language

Each row should show:

- label
- score label
- optional small bar or semantic icon
- tap to open insight sheet

#### D. CTA Row

Visible before the user scrolls deeply:

- primary: continuar / montar plano
- secondary: comparar cidades

## 3. Area Layout Details

### Overview

Components:

- `DecisionSummaryCard`
- `HighlightsGrid`
- `CriteriaSnapshotCard`
- `PrimaryCtaRow`

Should not contain:

- long explanation cards
- more than one paragraph of narrative

### Custo e chegada

Components:

- `ArrivalViabilityCard`
- `CostSummaryCard`
- `FlightBurdenCard` when route exists

Refactor guidance:

- merge overlapping financial signals when possible
- avoid repeating the same reserve/cost logic in different visual blocks
- show one top-line number first, then supporting numbers

Recommended order:

1. arrival pressure
2. reserve needed
3. monthly cost
4. flight burden

### Vida na pratica

Components:

- `CityNarrativeCard`
- `ClimateSummaryCard`
- `PeopleLikeYouCard`
- `NeighborhoodGuidanceCard`

Refactor guidance:

- each card should lead with one summary sentence
- long narrative should be converted into bullet-like highlights or collapsible detail
- chips should support reading, not become the only information surface

### Comparacao

Components:

- `CityStrengthsPanel`
- `InlineComparisonCard`

Refactor guidance:

- preserve comparison CTA
- strengthen the section as an anti-bias mechanism
- keep it lean when no alternatives exist

If there are no alternatives:

- keep `Strengths`
- hide the comparison card entirely

### Evidencias

Components:

- `SeasonalityEvidenceSection`
- `MapEvidenceSection`
- `PublicOpinionEvidenceSection`
- `DetailedAnalysisSection`
- `SourcesEvidenceSection`

Refactor guidance:

- default state collapsed by group
- each group subtitle should preview what it contains
- source transparency should be strongest here

## Content Mapping From Current UI

| Current block | New area | Action |
| --- | --- | --- |
| `_DecisionSnapshotPanel` | Overview | compress |
| `_QuickSummaryCard` | Overview | evolve into highlights strip |
| `_CategoryListCard` | Overview | keep with lighter density |
| `CityCostOfLivingCard` | Custo e chegada | keep, but simplify placement |
| `_ArrivalViabilityCard` | Custo e chegada | keep and promote |
| `_CityNarrativeCard` | Vida na pratica | keep with less text |
| `_ClimateSummaryCard` | Vida na pratica | keep |
| `_PeopleLikeYouCard` | Vida na pratica | keep |
| `_NeighborhoodGuidanceCard` | Vida na pratica | keep |
| `_CityStrengthsPanel` | Comparacao | keep |
| `_InlineComparisonCard` | Comparacao | keep |
| `CitySeasonalitySection` | Evidencias | move |
| `_CityLocationPanel` | Evidencias | move |
| `CityPublicOpinionSection` | Evidencias | move |
| `_CityAnalysisContent` | Evidencias | keep, split |
| `_DataTransparencyCard` + sources | Evidencias | keep and strengthen |

## Proposed Component Architecture

### New page composition

Keep the route and page entrypoint:

- `CityDetailPage`

Refactor into:

- `CityDetailScaffold`
- `CityDetailHero`
- `CityDetailSectionNav`
- `CityDetailOverviewSection`
- `CityDetailCostSection`
- `CityDetailLivingSection`
- `CityDetailComparisonSection`
- `CityDetailEvidenceSection`

### Suggested file strategy

Current page file is too large for safe iteration.

Target split:

- `pages/city_detail_page.dart`
- `widgets/detail/city_detail_scaffold.dart`
- `widgets/detail/city_detail_section_nav.dart`
- `widgets/detail/sections/city_detail_overview_section.dart`
- `widgets/detail/sections/city_detail_cost_section.dart`
- `widgets/detail/sections/city_detail_living_section.dart`
- `widgets/detail/sections/city_detail_comparison_section.dart`
- `widgets/detail/sections/city_detail_evidence_section.dart`
- `widgets/detail/cards/...`

### State and scroll model

Recommended:

- single scroll coordinator for the page
- section keys per primary area only
- internal expansion state only inside `Evidencias`

Avoid:

- dozens of top-level section keys
- global quick actions for every subsection

## Data Strategy

The current controller structure already supports staged rendering.

Useful existing separations in `CitiesController`:

- `socialProof`
- `climateSummary`
- `arrivalStory`
- `comparison`

### Loading strategy

#### Initial load

Render first:

- base city entity
- budget snapshot if available
- weather if available
- comparison context if already lightweight

Enough to render:

- hero
- overview
- cost and arrival shell

#### Deferred load

After first paint:

- social proof
- climate summary
- arrival story enrichment
- comparison payload
- evidence-only sections

This allows the top of the page to stabilize earlier.

## Interaction Rules

### Section navigation

- tapping a top tab scrolls to the corresponding section
- active tab updates based on scroll position
- tabs remain sticky while reading

### Cards

- every major card gets one primary takeaway
- secondary rationale opens in sheet or inline reveal

### Evidence groups

- collapsed by default
- can remember last opened state per session if useful

### Compare action

- should remain visible in `Overview` and `Comparacao`
- do not force user to scroll to find comparison

## Copy Rules

- one insight sentence first
- details later
- avoid two consecutive narrative paragraphs when one sentence plus bullets can do the same job
- labels must be short and unmistakable
- avoid generic CTAs such as `Ver mais` when the destination is thematic

## Design Constraints

- preserve current visual language, do not redesign the brand
- increase hierarchy contrast between primary and secondary content
- use spacing to separate layers of importance
- reduce repeated tinted panels that visually compete at the same level

## Implementation Order

## Phase 0 - Safety and preparation

Goal:

- reduce implementation risk before layout changes

Tasks:

1. split `city_detail_page.dart` into smaller widgets without changing behavior
2. isolate current section widgets into separate files
3. preserve current tests and navigation behavior

Definition of done:

- no UX changes yet
- file size is substantially reduced
- behavior is unchanged

## Phase 1 - New top architecture

Goal:

- fix first fold and navigation first

Tasks:

1. replace quick chip rail with sticky primary section nav
2. build new `Overview` area
3. move current CTA row into overview
4. reduce hero height and rebalance spacing

Definition of done:

- user can understand the page decision direction from the first fold
- user can navigate primary areas without relying on memory

## Phase 2 - Recompose content into primary areas

Goal:

- stop the long linear stack

Tasks:

1. regroup current blocks into `Custo`, `Vida`, `Comparacao`, `Evidencias`
2. remove generic `_SecondaryContentSection`
3. create explicit evidence groups

Definition of done:

- no more generic `Ver mais sobre {cidade}`
- all content still available
- top-level structure has 5 clear areas

## Phase 3 - Reduce reading cost per card

Goal:

- improve scannability inside each area

Tasks:

1. compress decision snapshot into one stronger summary card
2. turn quick summary into a highlights grid
3. shorten narrative-heavy cards
4. simplify repeated explanatory text

Definition of done:

- each card can be understood in one quick scan
- fewer long paragraphs in the main flow

## Phase 4 - Data and performance refinement

Goal:

- improve load behavior and responsiveness

Tasks:

1. stage deferred payload loads by section importance
2. add skeletons for section-level delayed content
3. measure rebuild frequency and scroll smoothness

Definition of done:

- page becomes useful earlier
- secondary content no longer blocks initial comprehension

## Phase 5 - Trust and personalization audit

Goal:

- align page interpretation with actual scoring logic

Tasks:

1. audit `weightedDecisionScore()`
2. fix any proxy mappings that misrepresent user priorities
3. expose clearer rationale for verdict generation

Definition of done:

- recommendation language is defensible
- personalized verdict reflects real inputs

## Technical Risks

### Risk 1

Sticky navigation and hero collapse may conflict with current header behavior.

Mitigation:

- prototype `NestedScrollView` first
- keep a temporary compatibility layer around the current header

### Risk 2

Large refactor inside a 7k+ line page can create regressions.

Mitigation:

- do Phase 0 before UX changes
- move components before redesigning them

### Risk 3

Re-grouping content may accidentally hide important data.

Mitigation:

- build a content inventory checklist from the current page
- validate every current section against the new mapping table

## Acceptance Criteria

The refactor is successful when:

- first fold answers the decision question in under a few seconds of reading
- the user always knows which major area they are in
- all current relevant information remains accessible
- evidence is still transparent and easy to inspect
- mobile scrolling feels shorter even without deleting content
- comparison is easier to discover
- the page logic remains technically maintainable

## Recommended First Delivery Slice

If the team wants the highest impact with lowest scope, implement this first slice:

1. Phase 0
2. sticky primary navigation
3. new overview area
4. move evidence content behind explicit groups

This alone should produce a meaningful UX improvement before deeper content rewriting.

## Next Step After Approval

After this proposal is approved, the next artifact should be:

- a UI implementation plan with component-by-component tasks
- followed by the actual Flutter refactor in phases
