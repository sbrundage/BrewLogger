# iOS 27 Roadmap

Where BrewLogger should invest against WWDC26. Ranked by user value, not effort.

---

## 1. App Intents

Make `Coffee` and `Brew` system-visible. One piece of entity modeling feeds Spotlight, Siri, Shortcuts, and our own search screen.

See [AppIntentsAdoption.md](AppIntentsAdoption.md). Blocked on [NavigationRouter.md](NavigationRouter.md).

**Caveat:** there is no food/beverage App Schema domain — shipped domains are messages, mail, photos, maps, and clock. This is general App Intents plus `.system.searchInApp`, not a schema adoption.

---

## 2. Foundation Models with image input

The on-device model gained vision in iOS 27. Point the camera at a bag of beans, get roaster, origin, process, varietal, and roast date into the add-coffee form.

Fits work already stubbed out:

- `Domain/UseCases/OriginLookUpUseCase.swift` — empty `// TODO:`
- `Presentation/Views/Shared/AutofillHighlight.swift` — already exists

Guided generation maps output onto our domain structs, so it lands behind the existing use-case boundary. On-device is sufficient; PCC not needed for label parsing.

Sessions: [241](https://developer.apple.com/videos/play/wwdc2026/241/), [237 @ 05:50](https://developer.apple.com/videos/play/wwdc2026/237/?time=350)

---

## 3. Live Activity for the brew timer

Pour-over and espresso timing on Lock Screen and Dynamic Island. `BrewTimerTextField+VM.swift` already exists. Static data goes in `ActivityAttributes`, dynamic in `ContentState`.

Low novelty — the session is foundations, not new-in-27 — but high user value.

Session: [223](https://developer.apple.com/videos/play/wwdc2026/223/)

---

## 4. SwiftData

We're on Core Data (`Data/CoreData/CoreDataStore.swift`). SwiftData added sectioned fetches (maps onto our Today/Yesterday grouping), custom types, `ResultsObserver`, and `HistoryObserver`.

The repository protocols keep a swap contained, but this is plumbing with no user-visible payoff. Revisit after App Intents ships.

Session: [274](https://developer.apple.com/videos/play/wwdc2026/274/)
