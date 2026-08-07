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
    public func fetch(coffeeId: String) throws -> Coffee? { coffees.first }
    public func fetchAll() throws -> [Coffee] { coffees }
    public func delete(id: String) throws { coffees.removeAll { $0.id == id } }
    public func update(_ coffee: Coffee) throws {
        if let i = coffees.firstIndex(where: { $0.id == coffee.id }) { coffees[i] = coffee }
    }
}

public final class StubBrewRepository: BrewRepository {

    // Preview/UI-test only: when set, re-spaces a brew's entries from its date on write.
    private let entrySpacing: TimeInterval?

    private var brews: [Brew]

    public init(brews: [Brew] = Brew.previewList, entrySpacing: TimeInterval? = nil) {
        self.entrySpacing = entrySpacing
        self.brews = brews
        self.brews = self.brews.map(spaced)
    }

    public func log(_ brew: Brew) throws { brews.append(spaced(brew)) }
    public func fetch(for brewId: String) throws -> Brew? { brews.first { $0.id == brewId } }
    public func fetchAll(for coffeeId: String?) throws -> [Brew] {
        guard let coffeeId else { return brews }
        return brews.filter { $0.coffee.id == coffeeId }
    }
    public func delete(id: String) throws { brews.removeAll { $0.id == id } }
    public func update(_ brew: Brew) throws {
        if let i = brews.firstIndex(where: { $0.id == brew.id }) { brews[i] = spaced(brew) }
    }

    private func spaced(_ brew: Brew) -> Brew {
        guard let entrySpacing else { return brew }
        let entries = brew.tastingEntries.enumerated().map { index, entry in
            TastingEntry(
                id: entry.id,
                createdAt: brew.date.addingTimeInterval(Double(index) * entrySpacing),
                rating: entry.rating,
                note: entry.note
            )
        }
        return brew.replacingEntries(entries)
    }
}

public struct StubGeocodingService: GeocodingService {
    private let result: GeocodeResult?

    public init(result: GeocodeResult? = nil) {
        self.result = result
    }

    public func geocode(_ query: String) async -> GeocodeResult? { result }
}

public final class StubBLEScaleRepository: BLEScaleRepository {
    public var connectionState: BLEConnectionState = .disconnected
    public var state​Changes: AsyncStream<BLEConnectionState> { AsyncStream { _ in } }
    public var readings: AsyncStream<ScaleReading> { AsyncStream { _ in } }

    public init() {}
    public func connect() {}
    public func disconnect() {}
    public func tare() {}
}
