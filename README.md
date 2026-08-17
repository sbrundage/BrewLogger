# BrewLogger

Track, dial in, and monitor your coffee brews over time.

BrewLogger is a Swift package for iOS that lets you log every brew, tie it back to
the coffee and its origin, and see what actually makes a cup taste better.

<!-- Optional: hero screenshot or logo -->
<!-- ![BrewLogger](Docs/Images/hero.png) -->

## Features

### Log a Brew

Capture method, dose, yield, grind, time, and tasting notes for every cup, then
rate it to dial in a recipe.

<!-- ![Log a brew](Docs/Images/brew.png) -->

### Organize Coffees

Group brews under each coffee with its origin, process, and roast details, and
compare ratings to find your best recipe.

<!-- ![Coffee details](Docs/Images/coffee.png) -->

### Origin Map

See where your coffees come from on an interactive map.

<!-- ![Origin map](Docs/Images/origin.png) -->

### Dashboard

Weekly highlights and brew statistics at a glance.

<!-- ![Dashboard](Docs/Images/dashboard.png) -->

### Bluetooth Scale

Connect a supported scale for live weight while you brew.

<!-- ![Scale](Docs/Images/scale.png) -->

## Architecture

BrewLogger is split into four layers, each its own SPM target:

- `Domain` - models, use cases, and repository protocols
- `Data` - Core Data persistence, Bluetooth scale, and geocoding
- `Application` - wiring and repository factory
- `Presentation` - SwiftUI views and view models

## Built With

- SwiftUI
- Core Data
- Core Bluetooth
- MapKit and Core Location
- Swift Charts
- Foundation Models
