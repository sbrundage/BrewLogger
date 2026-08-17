//
//  OriginHistoryMapViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import Foundation
import MapKit
import BrewLoggerApplication
import BrewLoggerDomain

extension OriginHistoryMapView {
    @MainActor @Observable
    final class ViewModel {
        struct CoffeeOriginLocation: Identifiable {
            let id: String
            let coffees: [Coffee]
            let coordinate: CLLocationCoordinate2D
            
            var singleCoffee: Coffee? {
                coffees.count == 1 ? coffees.first : nil
            }

            var title: String {
                singleCoffee?.name ?? "\(coffees.count) coffees"
            }
        }

        private struct Placed {
            let coffee: Coffee
            let key: String
            let coordinate: CLLocationCoordinate2D

            init?(_ coffee: Coffee) {
                guard let origin = coffee.originInfo, let latitude = origin.latitude, let longitude = origin.longitude
                else { return nil }
                self.coffee = coffee
                self.key = origin.groupingKey
                self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
        
        private let fetchCoffees: FetchAllCoffeesUseCase
        private let updateCoffee: UpdateCoffeeUseCase
        private let geocoding: GeocodingService

        private(set) var locations: [CoffeeOriginLocation] = []

        init(
            repository: CoffeeRepository = RepositoryFactory.dev.coffee,
            geocoding: GeocodingService = RepositoryFactory.dev.geocoding
        ) {
            self.fetchCoffees = FetchAllCoffeesUseCase(repository: repository)
            self.updateCoffee = UpdateCoffeeUseCase(repository: repository)
            self.geocoding = geocoding
        }

        func load() async {
            guard let coffees = try? fetchCoffees.execute() else { return }

            // Render coffees that already have coordinates immediately — don't block pins on geocoding.
            locations = groupedLocations(from: coffees)

            // Backfill any legacy coffees missing a coordinate once, then merge them in.
            if let backfilled = await backfillMissingCoordinates(coffees) {
                locations = groupedLocations(from: backfilled)
            }
        }

        func location(id: String) -> CoffeeOriginLocation? {
            locations.first { $0.id == id }
        }

        private func groupedLocations(from coffees: [Coffee]) -> [CoffeeOriginLocation] {
            let placed = coffees.compactMap(Placed.init)
            return Dictionary(grouping: placed, by: \.key).map { key, group in
                CoffeeOriginLocation(id: key, coffees: group.map(\.coffee), coordinate: group[0].coordinate)
            }
        }

        // Transitional backfill for coffees saved before entry-time geocoding; remove once location matching guarantees a coordinate.
        private func backfillMissingCoordinates(_ coffees: [Coffee]) async -> [Coffee]? {
            let unresolved = Set(coffees.compactMap { coffee -> String? in
                guard let origin = coffee.originInfo, !origin.hasCoordinate else { return nil }
                return origin.location
            })
            guard !unresolved.isEmpty else { return nil }

            var resultsByLocation: [String: GeocodeResult] = [:]
            for location in unresolved {
                resultsByLocation[location] = await geocoding.geocode(location)
            }
            guard !resultsByLocation.isEmpty else { return nil }

            return coffees.map { coffee in
                guard let origin = coffee.originInfo, !origin.hasCoordinate,
                      let result = resultsByLocation[origin.location]
                else { return coffee }
                let updated = coffee.withOrigin(origin.applying(result))
                try? updateCoffee.execute(coffee: updated)
                return updated
            }
        }
    }
}
