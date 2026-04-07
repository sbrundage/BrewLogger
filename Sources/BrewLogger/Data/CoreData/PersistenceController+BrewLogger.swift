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
        
        for _ in 0..<10 {
            let brew = BrewModel(context: controller.container.viewContext)
            brew.id = UUID().uuidString
            brew.date = Date()
            brew.dose = 18.0
            brew.yield = 36.0
            brew.brewTime = 28
            brew.method = 1
            brew.rating = 4
        }
        
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

        for coffee in coffees {
            let coffeeModel = CoffeeModel(context: controller.container.viewContext)
            coffeeModel.name = coffee.name
            coffeeModel.roaster = coffee.roaster
        }

        return controller
    }()
}
