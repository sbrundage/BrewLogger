//
//  OriginHistoryMapViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import Foundation
import MapKit
import CoreLocation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
final class OriginHistoryMapViewModel {
    struct CoffeeOriginLocation: Identifiable {
        let id: String
        let coffee: Coffee
        let coordinate: CLLocationCoordinate2D
    }

    private let fetchCoffees: FetchAllCoffeesUseCase

    private(set) var locations: [CoffeeOriginLocation] = []
    var isLoading = false

    init(repository: CoffeeRepository = RepositoryFactory.dev.coffee) {
        self.fetchCoffees = FetchAllCoffeesUseCase(repository: repository)
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        let coffees = (try? fetchCoffees.execute()) ?? []
        let withOrigin = coffees.compactMap { coffee -> (Coffee, String)? in
            guard let location = coffee.originInfo?.location else { return nil }
            return (coffee, location)
        }

        // TODO: Geocode each origin and append to locations
        // Example:
        // for (coffee, locationString) in withOrigin {
        //     if let placemarks = try? await CLGeocoder().geocodeAddressString(locationString),
        //        let coordinate = placemarks.first?.location?.coordinate {
        //         locations.append(CoffeeOriginLocation(id: coffee.id, coffee: coffee, coordinate: coordinate))
        //     }
        // }
    }
}
