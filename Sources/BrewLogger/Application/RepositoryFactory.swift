//
//  RepositoryFactory.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/9/26.
//

import Foundation
import BrewLoggerDomain
import BrewLoggerData
import CoreLogger

@MainActor
public struct RepositoryFactory {
    public let coffeeRepository: any CoffeeRepository
    public let brewRepository: any BrewRepository

    /// In-memory stub backed by domain model data. No CoreData required.
    /// Supports mutations (add/delete/update) — useful for exercising full UI interactions in previews.
    public static let stub = RepositoryFactory(
        coffeeRepository: StubCoffeeRepository(),
        brewRepository: StubBrewRepository()
    )

    /// CoreData-backed in-memory store seeded with coffee data.
    /// Use this when you want to exercise real persistence behavior (fetch, insert, delete) in previews.
    public static let preview: RepositoryFactory = {
        let context = PersistenceController.stubbedPreviewCoffees.container.viewContext
        let coffeeStore = CoreDataStore<CoffeeModel>(context: context)
        let brewStore = CoreDataStore<BrewModel>(context: context)
        return RepositoryFactory(
            coffeeRepository: CoreDataCoffeeRepository(store: coffeeStore),
            brewRepository: CoreDataBrewRepository(store: brewStore, coffeeStore: coffeeStore)
        )
    }()
}
