//
//  PersistenceController+BrewLogger.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 2/22/26.
//

import Foundation
import CoreLogger
import CoreData

public extension PersistenceController {
    @MainActor
    static let brewLogger = PersistenceController(
        modelName: "BrewLogger",
        bundle: .module
    )
    
    @MainActor
    static let previewBrew = PersistenceController(
        modelName: "BrewLogger",
        bundle: .module,
        inMemory: true
    )
    
    @MainActor
    static var stubbedPreviewBrews: PersistenceController = {
        let controller = PersistenceController(modelName: "BrewLogger", bundle: .module, inMemory: true)
        let context = controller.container.viewContext

        let coffee = CoffeeModel(context: context)
        coffee.id = UUID().uuidString
        coffee.name = "Rodrigo Sanchez"
        coffee.roaster = "KOS"

        for _ in 0..<10 {
            let brew = BrewModel(context: context)
            brew.id = UUID().uuidString
            brew.date = Date()
            brew.dose = 18.0
            brew.yield = 36.0
            brew.brewTime = 28
            brew.method = 1
            brew.rating = 4
            brew.coffee = coffee
        }

        try? context.save()
        return controller
    }()
    
    @MainActor
    static var stubbedPreviewCoffees: PersistenceController = {
        let controller = PersistenceController(modelName: "BrewLogger", bundle: .module, inMemory: true)

        let coffees: [(name: String, roaster: String)] = [
            ("Rodrigo Sanchez", "KOS"),
            ("El Puente", "KOS"),
            ("Guatemala", "KOS"),
            ("Andrews Cardona", "KOS"),
            ("Koke Washing Station", "KOS"),
            ("Strawberry Shake", "KOS"),
            ("Ana Maria Donneys", "Prarie House"),
            ("Drop Bear Espresso", "Kookaburra"),
        ]

        let context = controller.container.viewContext
        for coffee in coffees {
            let coffeeModel = CoffeeModel(context: context)
            coffeeModel.id = UUID().uuidString
            coffeeModel.name = coffee.name
            coffeeModel.roaster = coffee.roaster
        }

        try? context.save()
        return controller
    }()
}
