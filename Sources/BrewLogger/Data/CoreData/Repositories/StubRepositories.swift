//
//  StubRepositories.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/9/26.
//

import Foundation
import BrewLoggerDomain

public final class StubCoffeeRepository: CoffeeRepository {
    private var coffees: [Coffee] = Coffee.previewList

    public init() {}

    public func log(_ coffee: Coffee) throws { coffees.append(coffee) }
    public func fetchAll() throws -> [Coffee] { coffees }
    public func delete(id: String) throws { coffees.removeAll { $0.id == id } }
    public func update(_ coffee: Coffee) throws {
        if let i = coffees.firstIndex(where: { $0.id == coffee.id }) { coffees[i] = coffee }
    }
}

public final class StubBrewRepository: BrewRepository {
    private var brews: [Brew] = [Brew.preview]

    public init() {}

    public func log(_ brew: Brew) throws { brews.append(brew) }
    public func fetchAll(for coffeeId: String?) throws -> [Brew] {
        guard let coffeeId else { return brews }
        return brews.filter { $0.coffee.id == coffeeId }
    }
    public func delete(id: String) throws { brews.removeAll { $0.id == id } }
    public func update(_ brew: Brew) throws {
        if let i = brews.firstIndex(where: { $0.id == brew.id }) { brews[i] = brew }
    }
}

@MainActor
public final class StubBLEScaleRepository: BLEScaleRepository {
    public var connectionState: BLEConnectionState = .connected
    public var state​Changes: AsyncStream<BLEConnectionState> { AsyncStream { _ in } }
    public var readings: AsyncStream<ScaleReading> { AsyncStream { _ in } }

    public init() {}
    public func connect() {}
    public func disconnect() {}
    public func tare() {}
}
