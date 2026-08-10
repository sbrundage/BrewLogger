//
//  SaveCoffeeViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/1/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
final class SaveCoffeeViewModel {
    private let logCoffee: LogCoffeeUseCase
    private let updateCoffee: UpdateCoffeeUseCase
    private let geocoding: GeocodingService

    var coffee = CoffeeDraft()

    var canSave: Bool { coffee.canSave }
    var isEditing: Bool { coffee.id != nil }

    init(
        coffeeToEdit: Coffee? = nil,
        repository: CoffeeRepository = RepositoryFactory.dev.coffee,
        geocoding: GeocodingService = RepositoryFactory.dev.geocoding
    ) {
        self.logCoffee = LogCoffeeUseCase(repository: repository)
        self.updateCoffee = UpdateCoffeeUseCase(repository: repository)
        self.geocoding = geocoding

        if let coffeeToEdit {
            self.coffee = CoffeeDraft(coffee: coffeeToEdit)
        }
    }

    func saveCoffee() async throws -> Coffee {
        await resolveCoordinateIfNeeded()
        let coffee = coffee.toCoffee()

        // If we're updating an existing coffee, coffee id will already be set.  Otherwise save a new coffee
        self.coffee.id != nil ?
            try updateCoffee.execute(coffee: coffee) :
            try logCoffee.execute(coffee: coffee)

        return coffee
    }

    private func resolveCoordinateIfNeeded() async {
        guard !coffee.originLocation.isEmpty, coffee.needsGeocode else { return }
        guard let result = await geocoding.geocode(coffee.originLocation) else { return }
        coffee.geocode = result
        coffee.resolvedLocation = coffee.originLocation
    }
}

extension SaveCoffeeViewModel {    
    struct CoffeeDraft {
        var id: String? = nil
        var name = ""
        var roaster = ""
        var roastLevel: RoastLevel? = nil
        var roastDate: Date? = nil
        var originLocation = ""
        var originAltitude = ""
        var variety = ""
        var process: ProcessMethod? = nil
        var finishedAt: Date? = nil

        var geocode: GeocodeResult? = nil
        // The origin string the stored coordinate was resolved from; a mismatch means re-geocode.
        var resolvedLocation: String? = nil

        var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

        var needsGeocode: Bool {
            geocode == nil || resolvedLocation != originLocation
        }

        init() {}

        init(coffee: Coffee) {
            self.id = coffee.id
            self.name = coffee.name
            self.roaster = coffee.roastInfo?.roaster ?? ""
            self.roastLevel = coffee.roastInfo?.roastLevel
            self.roastDate = coffee.roastInfo?.date
            self.originLocation = coffee.originInfo?.location ?? ""
            self.originAltitude = coffee.originInfo?.altitude.map(String.init) ?? ""
            self.variety = coffee.variety ?? ""
            self.process = coffee.process
            self.finishedAt = coffee.finishedAt
            if let origin = coffee.originInfo, let result = origin.geocodeResult {
                self.geocode = result
                self.resolvedLocation = origin.location
            }
        }

        func toCoffee() -> Coffee {
            let roastInfo: RoastInfo? = (!roaster.isEmpty || roastLevel != nil || roastDate != nil)
                ? RoastInfo(
                    roaster: roaster.isEmpty ? nil : roaster,
                    date: roastDate,
                    roastLevel: roastLevel
                )
                : nil

            let originInfo: OriginInfo? = originLocation.isEmpty
                ? nil
                : OriginInfo(location: originLocation, altitude: Int(originAltitude), from: geocode)

            return Coffee(
                id: id ?? UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespaces),
                originInfo: originInfo,
                roastInfo: roastInfo,
                process: process,
                variety: variety.isEmpty ? nil : variety,
                finishedAt: finishedAt
            )
        }
    }
}
