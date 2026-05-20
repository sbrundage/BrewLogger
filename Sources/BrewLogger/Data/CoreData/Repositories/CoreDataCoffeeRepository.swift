//
//  CoreDataCoffeeRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation
import BrewLoggerDomain

public final class CoreDataCoffeeRepository: CoffeeRepository {
    private let store: CoreDataStore<CoffeeModel>
    
    public init(store: CoreDataStore<CoffeeModel>) {
        self.store = store
    }
        
    public func log(_ coffee: Coffee) throws {
        try store.insert { $0.update(from: coffee); $0.createdAt = Date() }
    }
    
    public func fetchAll() throws -> [Coffee] {
        // Brews are loaded via the CoffeeModel.brews relationship in toDomain()
        try store.fetchAll(
            sortDescriptors: [NSSortDescriptor(keyPath: \CoffeeModel.createdAt, ascending: false)]
        ).compactMap { $0.toDomain() }
    }
    
    public func delete(id: String) throws {
        try store.delete(id: id)
    }
    
    public func update(_ coffee: Coffee) throws {
        try store.update(id: coffee.id) {
            $0.update(from: coffee)
        }
    }
}
