//
//  CoreDataBrewRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/8/26.
//

import Foundation
import BrewLoggerDomain

public final class CoreDataBrewRepository: BrewRepository {
    private let store: CoreDataStore<BrewModel>
    // Read-only — used only to wire the Core Data relationship on save.
    // All Coffee CRUD lives in CoreDataCoffeeRepository.
    private let coffeeStore: CoreDataStore<CoffeeModel>
    
    public init(
        store: CoreDataStore<BrewModel>,
        coffeeStore: CoreDataStore<CoffeeModel>
    ) {
        self.store = store
        self.coffeeStore = coffeeStore
    }
        
    public func log(_ brew: Brew) throws {
        // Fetch parent CoffeeModel to set the managed object relationship.
        let coffeeModel = try coffeeStore.fetchOne(id: brew.coffeeId)
        try store.insert {
            $0.update(from: brew)
            $0.coffee = coffeeModel
        }
    }

    public func fetchAll(for coffeeId: String) throws -> [Brew] {
        // Predicate traverses the relationship — Core Data resolves coffee.id without requiring a separate join.
        let predicate = NSPredicate(format: "coffee.id == %@", coffeeId)
        return try store.fetchAll(predicate: predicate).compactMap { $0.toDomain() }
    }
    
    public func delete(id: String) throws {
        try store.delete(id: id)
    }
    
    public func update(_ brew: Brew) throws {
        try store.update(id: brew.id) {
            $0.update(from: brew)
        }
    }
}
