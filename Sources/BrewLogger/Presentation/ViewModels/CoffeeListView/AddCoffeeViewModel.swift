//
//  AddCoffeeViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/1/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
final class AddCoffeeViewModel {
    private let logCoffee: LogCoffeeUseCase

    var newCoffee = NewCoffee()

    var canSave: Bool { newCoffee.canSave }

    // Picker toggles
    var showRoastLevelPicker = false
    var showRoastDatePicker = false
    var showProcessPicker = false

    init(repository: CoffeeRepository = RepositoryFactory.dev.coffee) {
        self.logCoffee = LogCoffeeUseCase(repository: repository)
    }

    func saveCoffee() throws {
        try logCoffee.execute(coffee: newCoffee.toCoffee())
    }
}

extension AddCoffeeViewModel {
    struct NewCoffee {
        var name = ""
        var roaster = ""
        var roastLevel: RoastLevel? = nil
        var roastDate: Date? = nil
        var originLocation = ""
        var process: ProcessMethod? = nil

        var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

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
                : OriginInfo(location: originLocation, altitude: nil)

            return Coffee(
                name: name.trimmingCharacters(in: .whitespaces),
                originInfo: originInfo,
                roastInfo: roastInfo,
                process: process
            )
        }
    }
}
