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

    public static let stub = RepositoryFactory(
        coffee: StubCoffeeRepository(),
        brew: StubBrewRepository()
    )
    
    // public static let scale: BLEScaleRepository = CoreBluetoothScaleRepository()
}
