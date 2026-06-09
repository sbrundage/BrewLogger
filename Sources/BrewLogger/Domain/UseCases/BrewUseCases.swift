//
//  BrewUseCases.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 1/3/26.
//

import Foundation

public struct LogBrewUseCase {
    private let repository: BrewRepository
    
    public init(repository: BrewRepository) {
        self.repository = repository
    }
    
    public func execute(newBrew: Brew) throws {
        try repository.log(newBrew)
    }
}

public struct FetchAllBrewsUseCase {
    private let repository: BrewRepository
    
    public init(repository: BrewRepository) {
        self.repository = repository
    }
    
    public func execute(coffeeId: String?) throws -> [Brew] {
        try repository.fetchAll(for: coffeeId)
    }
}

public struct DeleteBrewUseCase {
    private let repository: BrewRepository
    
    public init(repository: BrewRepository) {
        self.repository = repository
    }
    
    public func execute(brewId: String) throws {
        try repository.delete(id: brewId)
    }
}

public struct UpdateBrewUseCase {
    private let repository: BrewRepository
    
    public init(repository: BrewRepository) {
        self.repository = repository
    }
    
    public func execute(updatedBrew: Brew) throws {
        try repository.update(updatedBrew)
    }
}
