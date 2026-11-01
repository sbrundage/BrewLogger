# Navigation Router

Moving navigation from view-local `@State` to a shared, injectable router.

---

## Why

App Intents run `perform()` outside the view tree. To open a screen, an intent needs a reference to navigation state. Today all of that state is `private` and view-local, so nothing outside a view can drive it.

Independent benefit: navigation state becomes testable.

---

## What's already right

| Thing | Where |
|---|---|
| Value-based routing | `CoffeeListView.swift:93` → `:72` (`navigationDestination(for: Coffee.self)`) |
| A `NavigationPath` exists | `DashboardView.swift:17` |
| Entities have stable IDs | `Coffee.swift:10`, `Brew.swift:10` — `Identifiable`, `Sendable`, `String` id |

The idiom is already here. It just isn't used everywhere, and the state isn't shared.

---

## What blocks us

**1. Path is unreachable.** `@State private var path` — `DashboardView.swift:17`.

**2. Route enums are file-private.** `AddRoute` (`DashboardView.swift:9`), `SeeAllRoute` (`DashboardContent.swift:11`). Intent code can't name them.

**3. Three independent stacks, and the TabView isn't in this package.** `DashboardView:23`, `MainCoffeeView:15`, and `MainBrewView:29` each create their own `NavigationStack`; the two `Main*` views have no path binding at all. PocketLogger owns the tab bar, so a deep link must select the tab and then push.

**4. Destination-based links can't be triggered programmatically.** `NavigationLink { Destination() }` only responds to taps. Convert to `NavigationLink(value:)`:

- `DashboardContent.swift:59`, `:73`
- `WeeklyHighlightView.swift:44`, `:63`
- `BrewListView.swift:129`
- `OriginHistoryMapView.swift:134`

**5. `navigationDestination(isPresented:)` on local `@State`** — `CoffeeDetailsView.swift:55`, `:58`.

**6. Sheets on local `@State`** — `coffeeToEdit` / `showAddCoffeeSheet` (CoffeeListView), `brewToEdit` / `showAddBrewSheet` (BrewListView). Only needed for mutating intents, not plain navigation. Defer.

---

## How

One `@Observable Router`, public API of `BrewLoggerPresentation` so both PocketLogger's `TabView` and the intents can reach it:

```
Router
├─ selectedTab: Tab
└─ paths: [Tab: NavigationPath]
```

- Public `Route` enum replacing `AddRoute` and `SeeAllRoute`, cases keyed by entity id rather than by model, so intents can route without a fetch.
- Inject via `.environment`. The three `Main*` views take a path binding instead of owning one.
- Intents call `router.navigate(to:)` — see [AppIntentsAdoption.md](AppIntentsAdoption.md).

**Order:** router and public `Route` → hoist paths out of the three `Main*` views → convert the six links in (4) → `CoffeeDetailsView` (5). Sheets (6) last, or never.

Roughly half a day.

---

## References

Nothing in WWDC26 covers navigation architecture — no 2026 session mentions `NavigationStack` or `NavigationPath`. It was settled in 2022 and not revisited.

| Source | Why |
|---|---|
| [WWDC22 — The SwiftUI cookbook for navigation](https://developer.apple.com/videos/play/wwdc2022/10054/) | The reference. Covers programmatic navigation (our exact problem) and state persistence (recipe at 18:12). |
| [WWDC23 — Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/) | `@Observable` for the `Router`. Mostly confirmation — we already use it (`DashboardView.swift:15`). |
| [Migrating to new navigation types](https://developer.apple.com/documentation/swiftui/migrating-to-new-navigation-types) | Written checklist for converting the six links. |

Skip the cookbook's `NavigationSplitView` recipes — we're three stacks under a TabView, not multi-column.

**Design consequences for `Route`:** `NavigationPath` is `Codable`, so `SceneStorage` restoration requires `Route` to be `Codable`. Adopting `AppEnum` for intents requires a `String` raw value. Both point the same way — key cases by entity id, not by model.
