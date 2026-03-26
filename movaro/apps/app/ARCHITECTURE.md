# Flutter App Architecture

## Goal

Keep `core` restricted to cross-cutting technical building blocks and place
product capabilities inside `features`.

## Folder Rules

- `lib/app`
  - App shell, bootstrap, routing, theme, localization, and app-level pages.
- `lib/core`
  - Shared infrastructure and reusable UI primitives only.
  - Examples: network, environment, persistence helpers, design system widgets.
- `lib/features/<feature>`
  - Business capability modules.
  - Prefer splitting by `application`, `domain`, `data`, and `presentation`
    when the feature justifies it.

## Current Capability Boundaries

- `features/catalog`
  - Country catalog entities, repository contracts, and data sources.
- `features/journey`
  - Journey state, journey selection rules, and journey setup UI.
- `features/location`
  - Device/location orchestration and location permission/banner UI.
- `app/presentation/pages`
  - App shell pages that are not product features, such as settings and
    protected placeholders.

## Dependency Rules

- `app` may depend on `core` and `features`.
- `features` may depend on `core`.
- A feature may depend on another feature only when the dependency is explicit
  and business-driven.
- `core` must not depend on `features`.

## Practical Conventions

- Put controllers/state orchestrators in `application`.
- Put repository interfaces and entities in `domain`.
- Put adapters, DTOs, and external data sources in `data`.
- Put screens and widgets in `presentation`.
- Avoid creating new top-level shared folders outside `app`, `core`, and
  `features`.

## Refactoring Guardrails

- If a module contains business language, it probably belongs in `features`.
- If a widget is reusable across multiple features without business context, it
  belongs in `core/widgets`.
- If a file is only used by app bootstrapping or navigation, it belongs in
  `app`.
