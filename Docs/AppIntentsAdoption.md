# App Intents Adoption

Exposing `Coffee` and `Brew` to Spotlight, Siri, and Shortcuts.

---

## Why

One piece of entity modeling feeds four surfaces: Spotlight, Siri, Shortcuts, and our own search screen. Nothing else on the [roadmap](iOS27Roadmap.md) has that fan-out.

Indexing also buys semantic search rather than literal matching, so "that natural Ethiopian" resolves without an exact name match.

---

## Constraint: no matching schema domain

App Schemas cover messages, mail, photos, maps, and clock. There is no food or beverage domain, so we get no free natural-language handling for "log a V60."

This is general App Intents plus `.system.searchInApp`, a system-domain schema that works regardless of which other domains we adopt and even without indexing. Plan around explicit intents, not schema conformance.

---

## What we build

| Piece | Maps to |
|---|---|
| `CoffeeEntity` : `AppEntity`, `IndexedEntity` | `Coffee` — already `Identifiable`, `Sendable`, `String` id |
| `BrewEntity` : `AppEntity`, `IndexedEntity` | `Brew` — same |
| `EntityQuery` for each | `CoffeeRepository` / `BrewRepository` |
| `OpenIntent` | `Router.navigate(to:)` — see [NavigationRouter.md](NavigationRouter.md) |
| `.system.searchInApp` | `Views/Search/SearchResultsView.swift` (in progress) |
| `IntentValueQuery` | Structured lookup: "brews with the Ethiopian" |

Domain models need no changes. Entity conformances are additive and belong in the app target or a new module, not `BrewLoggerDomain` — keep the domain framework-free.

---

## Phases

1. Blocked on the router. Do [NavigationRouter.md](NavigationRouter.md) first.
2. One parameterless navigation intent — open New Brew via `router.navigate(to: .brew)`, `@MainActor` on `perform`, `supportedModes = .foreground`. ~20 lines. Proves target setup and the router with no entity design.
3. `AppEnum` on the section/tab enum, so one parameterized intent replaces N hardcoded ones. Requires a `String` raw value, `TypeDisplayRepresentation`, and `caseDisplayRepresentation`.
4. `CoffeeEntity` + `EntityQuery` + `OpenIntent`. Coffee before Brew: `Brew` embeds a `Coffee` (`Brew.swift:12`), and `Coffee` has a natural title in `name` while a brew's must be synthesized.
5. `BrewEntity`, same shape.
6. `IndexedEntity` on both, for the Spotlight semantic index.
7. `.system.searchInApp` — wire Siri's search string into `SearchResultsView`.
8. Mutating intents (log a brew, rate a brew). Requires router-driven sheets, deferred in the navigation doc.

Phases 1–6 stand alone. Stop there if the payoff isn't visible.

**Open question, settle before phase 4:** `CoffeeListView.swift:93` gates navigation on `coffee.hasDetails`, so coffees without origin, roast, or process aren't reachable. Either make the detail screen handle a bare coffee, or filter the `EntityQuery` to `hasDetails`. This decides what the entity set is.

---

## Testing

`AppIntentsTesting` (new this year) unit-tests intents, entity queries, and Spotlight indexing directly. Fits how this repo already tests view models — add coverage per phase, not at the end.

---

## References

| Source | Why |
|---|---|
| [WWDC25 244 — Get to know App Intents](https://developer.apple.com/videos/play/wwdc2025/244/) | Start here. First intent at 03:25, shared navigator at 03:46, `AppEnum` at 05:01, `OpenIntent` at 18:17. |
| [240 — Build intelligent Siri experiences with App Schemas](https://developer.apple.com/videos/play/wwdc2026/240/) | Concepts. App Entities (04:06), IndexedEntity (06:21). |
| [344 — Code-along: Make your app available to Siri](https://developer.apple.com/videos/play/wwdc2026/344/) | Hands-on, entity by entity. `OpenIntent` at 14:34. |
| [345 — Discover new capabilities in the App Intents framework](https://developer.apple.com/videos/play/wwdc2026/345/) | What's new this year. |
| [343 — Explore advanced App Intents features](https://developer.apple.com/videos/play/wwdc2026/343/) | Highest value for us. IndexedEntity (11:59), IntentValueQuery (13:32), in-app search (15:27). |
| [295 — Validate your App Intents adoption with AppIntentsTesting](https://developer.apple.com/videos/play/wwdc2026/295/) | Entity queries (09:39), Spotlight indexing (18:22). |
| [347 — Secure your app: mitigate risks to agentic features](https://developer.apple.com/videos/play/wwdc2026/347/) | Before shipping phase 6. |
