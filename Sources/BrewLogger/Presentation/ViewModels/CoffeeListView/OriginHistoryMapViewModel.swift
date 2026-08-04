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
            
            var title: String {
                coffees.count == 1 ? coffees[0].name : "\(coffees.count) coffees"
            }

            var singleCoffee: Coffee? {
                coffees.count == 1 ? coffees.first : nil
            }
        }
        
        private let fetchCoffees: FetchAllCoffeesUseCase
        private let coordinateCache: OriginCoordinateCache

        private(set) var locations: [CoffeeOriginLocation] = []

        var isLoading = false

        init(
            repository: CoffeeRepository = RepositoryFactory.dev.coffee,
            coordinateCache: OriginCoordinateCache = UserDefaultsOriginCoordinateCache()
        ) {
            self.fetchCoffees = FetchAllCoffeesUseCase(repository: repository)
            self.coordinateCache = coordinateCache
        }
        
        func load() async {
            isLoading = true
            defer { isLoading = false }
            
            guard let coffees = try? fetchCoffees.execute() else { return }
            
            let coffeesByOrigin = Dictionary(
                grouping: coffees.compactMap { coffee -> (Coffee, String)? in
                    coffee.originInfo.map { (coffee, $0.location) }
                },
                by: { $0.1 }
            ).mapValues { $0.map(\.0) }
            
            var results: [CoffeeOriginLocation] = []
            for (location, coffeesAtOrigin) in coffeesByOrigin {
                guard let coordinate = await coordinate(for: location) else { continue }
                results.append(CoffeeOriginLocation(id: location, coffees: coffeesAtOrigin, coordinate: coordinate))
            }
            locations = results
        }
        
        func location(id: String) -> CoffeeOriginLocation? {
            locations.first { $0.id == id }
        }
        
        private func coordinate(for location: String) async -> CLLocationCoordinate2D? {
            if let cached = coordinateCache.coordinate(for: location) { return cached }
            guard
                let request = MKGeocodingRequest(addressString: location),
                let mapItems = try? await request.mapItems,
                let coordinate = mapItems.first?.location.coordinate
            else { return nil }
            coordinateCache.save(coordinate, for: location)
            return coordinate
        }
    }
}
