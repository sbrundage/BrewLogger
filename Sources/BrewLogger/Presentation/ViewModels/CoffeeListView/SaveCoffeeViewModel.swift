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

    var coffee = CoffeeDraft()
    
    var canSave: Bool { coffee.canSave }
    var isEditing: Bool { coffee.id != nil }

    init(
        coffeeToEdit: Coffee? = nil,
        repository: CoffeeRepository = RepositoryFactory.dev.coffee
    ) {
        self.logCoffee = LogCoffeeUseCase(repository: repository)
        self.updateCoffee = UpdateCoffeeUseCase(repository: repository)
        
        if let coffeeToEdit {
            self.coffee = CoffeeDraft(coffee: coffeeToEdit)
        }
    }

    func saveCoffee() throws -> Coffee {
        let coffee = coffee.toCoffee()
        
        // If we're updating an existing coffee, coffee id will already be set.  Otherwise save a new coffee
        self.coffee.id != nil ?
            try updateCoffee.execute(coffee: coffee) :
            try logCoffee.execute(coffee: coffee)
        
        return coffee
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

        var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
        
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
                : OriginInfo(location: originLocation, altitude: Int(originAltitude))

            return Coffee(
                id: id ?? UUID().uuidString,
                name: name.trimmingCharacters(in: .whitespaces),
                originInfo: originInfo,
                roastInfo: roastInfo,
                process: process,
                variety: variety.isEmpty ? nil : variety
            )
        }
    }
}
