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
    private let coffeeToEdit: Coffee?

    var coffeeDraft = CoffeeDraft()

    var isEditing: Bool { coffeeToEdit != nil }
    var canSave: Bool {
        coffeeDraft.canSave && coffeeDraft.toCoffee() != coffeeToEdit
    }

    init(
        coffeeToEdit: Coffee? = nil,
        repository: CoffeeRepository = RepositoryFactory.dev.coffee,
        geocoding: GeocodingService = RepositoryFactory.dev.geocoding
    ) {
        self.logCoffee = LogCoffeeUseCase(repository: repository)
        self.updateCoffee = UpdateCoffeeUseCase(repository: repository)
        self.geocoding = geocoding
        self.coffeeToEdit = coffeeToEdit
        
        if let coffeeToEdit {
            self.coffeeDraft = CoffeeDraft(coffee: coffeeToEdit)
        }
    }

    func saveCoffee() async throws -> Coffee {
        await resolveCoordinateIfNeeded()
        let coffee = reactiveIfRoastDateChanged(coffeeDraft.toCoffee())
        
        isEditing ?
            try updateCoffee.execute(coffee: coffee) :
            try logCoffee.execute(coffee: coffee)
            
        return coffee
    }
}

private extension SaveCoffeeViewModel {
    func resolveCoordinateIfNeeded() async {
        guard !coffeeDraft.originLocation.isEmpty, coffeeDraft.needsGeocode else { return }
        guard let result = await geocoding.geocode(coffeeDraft.originLocation) else { return }
        coffeeDraft.geocode = result
        coffeeDraft.resolvedLocation = coffeeDraft.originLocation
    }
    
    // If coffee is edited and roast date is changed, we should clear the coffee's `finishedAt` date.
    func reactiveIfRoastDateChanged(_ coffee: Coffee) -> Coffee {
        guard
            let coffeeToEdit,
            coffee.roastInfo?.date != coffeeToEdit.roastInfo?.date
        else { return coffee }
        return coffee.markingFinished(nil)
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
