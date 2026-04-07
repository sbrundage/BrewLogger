//
//  CoffeeUseCases.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/6/26.
//

import Foundation

public struct LogCoffeeUseCase {
    private let repository: CoffeeRepository

    public init(repository: CoffeeRepository) {
        self.repository = repository
    }

    public func execute(coffee: Coffee) throws {
        try repository.log(coffee)
    }
}

public struct FetchAllCoffeesUseCase {
    private let repository: CoffeeRepository

    public init(repository: CoffeeRepository) {
        self.repository = repository
    }

    public func execute() throws -> [Coffee] {
        try repository.fetchAll()
    }
}

public struct DeleteCoffeeUseCase {
    private let repository: CoffeeRepository

    public init(repository: CoffeeRepository) {
        self.repository = repository
    }

    public func execute(coffeeId: String) throws {
        try repository.delete(id: coffeeId)
    }
}

public struct UpdateCoffeeUseCase {
    private let repository: CoffeeRepository

    public init(repository: CoffeeRepository) {
        self.repository = repository
    }

    public func execute(coffee: Coffee) throws {
        try repository.update(coffee)
    }
}
