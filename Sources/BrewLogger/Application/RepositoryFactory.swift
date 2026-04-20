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
    public let scale: any BLEScaleRepository

    public static let stub = RepositoryFactory(
        coffee: StubCoffeeRepository(),
        brew: StubBrewRepository(),
        scale: StubBLEScaleRepository()
    )
    
    // TODO: Add dev repositories - Move away from stub repos and pass in CoreDataStore created from host app
    public static let dev = RepositoryFactory(
        coffee: StubCoffeeRepository(),
        brew: StubBrewRepository(),
        scale: CoreBluetoothScaleRepository()
    )
}
