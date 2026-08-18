# BrewLogger

Track, dial in, and monitor your coffee brews over time.

BrewLogger is a Swift package for iOS that lets you log every brew, tie it back to the coffee and its origin, and see what actually makes a cup taste better.

This repo is the package. The shipping app, PocketLogger, is a separate project that composes and implements this library.

## Features

### Log a Brew

Capture method, dose, yield, grind, time, and tasting notes for every cup, then rate it to dial in a recipe.

Add a Brew | Select a Coffee & Method |
-| -|
![Add Brew](https://github.com/user-attachments/assets/56dd7657-4e6a-4091-914b-66e210cdf0d4) |  ![Select Coffee](https://github.com/user-attachments/assets/1630d4dc-412f-4cf6-af0d-af675b861322) |

### View Brew History

Every brew you've logged, grouped by day under Today, Yesterday, and dated headers so you can see how a recipe changed over time.

Sort by:

- **Newest** - most recent brew first, kept in day groups
- **Highest Rated** - best cups first, flattened into a single list

Search by coffee name to narrow the list to one coffee's brews.

Brew History | Sort Options | Search by Coffee |
-| -| -|
![Brew History](https://github.com/user-attachments/assets/53c12dd0-dad5-4962-8cd4-0e8d4b75fd3a) | ![Brew Sort Options](https://github.com/user-attachments/assets/ce0a522e-e0f7-4f3c-a6d3-97ce7fffb87d) | ![Search Brews](https://github.com/user-attachments/assets/3a0a3d5a-adc3-4094-94c6-a8c42d1de680) |

### View Coffee History

Group brews under each coffee with its origin, process, and roast details, and compare ratings to find your best recipe.

Sort by:

- **Recently Brewed** - whatever you reached for last
- **Most Brewed** - your highest-volume coffees
- **Highest Rated** - ranked by each coffee's best-rated brew
- **Freshest Roast** - most recent roast date first

Search matches coffee name, roaster, and origin, so "Ethiopia" or a roaster's name pulls up everything from them.

Coffee History | Sort Options | Search by Origin |
-| -| -|
![Coffee History](https://github.com/user-attachments/assets/30e2640c-b6cf-4ae9-b917-cefdb3b924f6) | ![Coffee Sort Options](https://github.com/user-attachments/assets/0d4c5c32-727f-4753-83f9-791200418bd4) | ![Search by Origin](https://github.com/user-attachments/assets/de443fe4-ff87-40ce-bfbb-415c6f9eb5cf) |

### Dashboard

Weekly highlights and brew statistics at a glance.

![Dashboard](https://github.com/user-attachments/assets/316bd6ba-c228-43d3-beac-55f3c79a46e7)

### Search

Find any coffee or brew from one place. 
[In Progress]

### Origin Map

See where your coffees come from on an interactive map.

![Origin History Map](https://github.com/user-attachments/assets/96c61b59-3b23-41dd-bb4b-3fd411d04c2a)

### Bluetooth Scale

Live weight while you brew, streamed from a scale I built myself - an ESP32 load cell rig with firmware at [BLEScale-ESP32](https://github.com/sbrundage/BLEScale-ESP32). No commercial scales are supported yet.

![Logging a brew](https://github.com/user-attachments/assets/2f9098f5-151d-4f36-bf4c-23592e408b0c)

## Requirements

- iOS 26+
- Swift 6.2 / Xcode 26

## Installation

```swift
.package(url: "https://github.com/sbrundage/BrewLogger.git", branch: "develop")
```

Then depend on the product you need:

```swift
.product(name: "BrewLoggerPresentation", package: "BrewLogger")  // SwiftUI views
.product(name: "BrewLoggerApplication", package: "BrewLogger")   // wiring only
```

## Architecture

Four SPM targets, each depending only on the ones below it:

- `BrewLoggerPresentation` - SwiftUI views and `@Observable` view models
- `BrewLoggerApplication` - composition root; `RepositoryFactory` wires Data to Domain
- `BrewLoggerData` - Core Data persistence, Bluetooth scale, geocoding
- `BrewLoggerDomain` - models and repository protocols; pure Swift, no dependencies

## Built With

- **SwiftUI** - the entire UI layer
- **Core Data** - local store for coffees and brews, behind repository protocols
- **Core Bluetooth** - connects the custom ESP32 scale and streams weight at 10 Hz
- **MapKit / Core Location** - geocodes origins and renders the origin map
- **Swift Charts** - tasting timeline and live scale weight
- **Foundation Models** - on-device streamed origin summaries

## License

MIT - see [LICENSE](LICENSE).
