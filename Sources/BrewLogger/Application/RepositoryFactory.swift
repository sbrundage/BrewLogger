//
//  RepositoryFactory.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/9/26.
//

import CoreData
import Foundation
import BrewLoggerDomain
import BrewLoggerData
import CoreLogger

@MainActor
public struct RepositoryFactory {
    public let coffee: any CoffeeRepository
    public let brew: any BrewRepository
    public let scale: any BLEScaleRepository

    // Fully in-memory — no BLE, no CoreData. Safe to use anywhere without hardware.
    public static let stub = RepositoryFactory(
        coffee: StubCoffeeRepository(),
        brew: StubBrewRepository(),
        scale: StubBLEScaleRepository()
    )

    // Starts as stubs so default init params work safely before configure() runs.
    // Host app calls configure(context:) in App.init() to upgrade to real repos.
    public private(set) static var dev: RepositoryFactory = .stub

    // Single CBCentralManager instance — creating more than one causes BLE issues.
    private static let bleRepository = CoreBluetoothScaleRepository()

    /// Call once from App.init() before any views load.
    /// Replaces stub repos with real CoreData-backed ones.
    public static func configure(with persistenceController: PersistenceController) {
        let context = persistenceController.container.viewContext
        let coffeeStore = CoreDataStore<CoffeeModel>(context: context)
        dev = RepositoryFactory(
            coffee: CoreDataCoffeeRepository(store: coffeeStore),
            brew: CoreDataBrewRepository(
                store: CoreDataStore<BrewModel>(context: context),
                coffeeStore: coffeeStore
            ),
            scale: bleRepository
        )
        seedPlaceholderCoffeeIfNeeded(coffeeRepo: dev.coffee)
    }

    /// Seeds a single placeholder coffee on first launch so brews can be logged
    /// before the Add Coffee UI is built. Remove once real coffee creation exists.
    private static func seedPlaceholderCoffeeIfNeeded(coffeeRepo: any CoffeeRepository) {
        guard (try? coffeeRepo.fetchAll())?.isEmpty == true else { return }
        let placeholder = Coffee(
            id: "placeholder-rodrigo-sanchez",
            name: "Rodrigo Sanchez",
            originInfo: nil,
            roastInfo: nil,
            process: nil
        )
        try? coffeeRepo.log(placeholder)
    }
}
