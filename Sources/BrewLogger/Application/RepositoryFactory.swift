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
    public let coffee: CoffeeRepository
    public let brew: BrewRepository
    public let scale: BLEScaleRepository
    
    public static let stub = RepositoryFactory(
        coffee: StubCoffeeRepository(),
        // entrySpacing lets previews build the taste-over-time chart without waiting real minutes.
        brew: StubBrewRepository(entrySpacing: 8 * 60),
        scale: StubBLEScaleRepository()
    )

    // Starts as stubs. Host app calls configure(context:) in App.init() to upgrade to real repos.
    public private(set) static var dev: RepositoryFactory = .stub

    private static let bleRepository = CoreBluetoothScaleRepository()

    /// Call once from App.init(). Replaces stub repos with real CoreData-backed ones.
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
    }
}
