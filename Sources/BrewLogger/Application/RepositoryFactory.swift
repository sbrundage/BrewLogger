//
//  RepositoryFactory.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/9/26.
//

import Foundation
import BrewLoggerDomain
import BrewLoggerData

public struct RepositoryFactory {
    public static func makeBrew(for environment: EnvironmentType) -> BrewRepository {
        switch environment {
        case .stub:
            StubBrewRepository()
        }
    }
    
    public static func makeCoffee(for environment: EnvironmentType) -> CoffeeRepository {
        switch environment {
        case .stub:
            StubCoffeeRepository()
        }
    }
}
