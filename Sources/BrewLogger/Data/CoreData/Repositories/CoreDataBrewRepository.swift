//
//  CoreDataBrewRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/8/26.
//

import Foundation
import BrewLoggerDomain

/// Repository responsible for managing Brew model persistence within CoreData.
/// Supports logging, fetching, updating and deleting.
public final class CoreDataBrewRepository: BrewRepository {
    private let store: CoreDataStore<BrewModel>
    private let coffeeStore: CoreDataStore<CoffeeModel>
    
    public init(
        store: CoreDataStore<BrewModel>,
        coffeeStore: CoreDataStore<CoffeeModel>
    ) {
        self.store = store
        self.coffeeStore = coffeeStore
    }
    
    /// Logs a particular brew in CoreData.
    /// - Parameter brew: Brew model to persist
    public func log(_ brew: Brew) throws {
        let coffeeModel = try coffeeStore.fetchOne(id: brew.coffee.id)
        try store.insert {
            $0.update(from: brew)
            $0.coffee = coffeeModel
        }
    }
    
    public func fetch(for brewId: String) throws -> Brew? {
        try store.fetchOne(id: brewId)?.toDomain()
    }
    
    /// Fetches all Brews for a particular coffee ID if present, otherwise returns all persisted Brews
    /// - Parameter coffeeId: Optional ID for a Coffee model
    /// - Returns: An array of Brew objects
    public func fetchAll(for coffeeId: String?) throws -> [Brew] {
        let predicate = coffeeId.map { NSPredicate(format: "coffee.id == %@", $0) }
        return try store.fetchAll(
            predicate: predicate,
            sortDescriptors: [NSSortDescriptor(keyPath: \BrewModel.date, ascending: false)]
        ).compactMap { $0.toDomain() }
    }
    
    /// Deletes a particular Brew from CoreData
    /// - Parameter id: ID of the Brew model to delete from storage
    public func delete(id: String) throws {
        try store.delete(id: id)
    }
    
    /// Updates a particular Brew in CoreData
    /// - Parameter brew: Updated Brew model to be persisted
    public func update(_ brew: Brew) throws {
        let coffeeModel = try coffeeStore.fetchOne(id: brew.coffee.id)
        try store.update(id: brew.id) {
            $0.update(from: brew)
            $0.coffee = coffeeModel
        }
    }
}
