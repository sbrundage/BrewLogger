//
//  RepositoryFactory.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/9/26.
//

import Foundation
import BrewLoggerDomain
import BrewLoggerData

@MainActor
public struct RepositoryFactory {
    public let coffee: any CoffeeRepository
    public let brew: any BrewRepository

    // One shared instance — stub repos share the same in-memory state
    public static let stub = RepositoryFactory(
        coffee: StubCoffeeRepository(),
        brew: StubBrewRepository()
    )
}
