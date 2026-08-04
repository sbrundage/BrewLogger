//
//  OriginCoordinateCacheTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/4/26.
//

@testable import BrewLoggerPresentation

import CoreLocation
import Foundation
import Testing

@Suite("UserDefaultsOriginCoordinateCache")
struct OriginCoordinateCacheTests {
    let store = StubKeyValueStore()
    let sut: UserDefaultsOriginCoordinateCache

    init() {
        sut = UserDefaultsOriginCoordinateCache(store: store)
    }

    // MARK: - Lookup

    @Test("Unknown location returns nil")
    func testCoordinate_whenLocationUnknown_shouldReturnNil() {
        #expect(sut.coordinate(for: "Nowhere") == nil)
    }

    @Test("Saved coordinate is returned")
    func testSave_thenCoordinate_shouldReturnStoredCoordinate() {
        // Act
        sut.save(CLLocationCoordinate2D(latitude: 2.9, longitude: -75.3), for: "Huila, Colombia")

        // Assert
        expectCoordinate(sut.coordinate(for: "Huila, Colombia"), equals: 2.9, -75.3)
    }

    @Test("Saving an existing location overwrites it")
    func testSave_whenLocationExists_shouldOverwrite() {
        // Arrange
        sut.save(CLLocationCoordinate2D(latitude: 1, longitude: 1), for: "Yirgacheffe, Ethiopia")

        // Act
        sut.save(CLLocationCoordinate2D(latitude: 6.2, longitude: 38.2), for: "Yirgacheffe, Ethiopia")

        // Assert
        expectCoordinate(sut.coordinate(for: "Yirgacheffe, Ethiopia"), equals: 6.2, 38.2)
    }

    // MARK: - Persistence

    @Test("Saving writes through to the store")
    func testSave_shouldWriteThroughToStore() {
        // Act
        sut.save(CLLocationCoordinate2D(latitude: 2.9, longitude: -75.3), for: "Huila, Colombia")

        // Assert — a fresh cache over the same store hydrates the value.
        let rehydrated = UserDefaultsOriginCoordinateCache(store: store)
        expectCoordinate(rehydrated.coordinate(for: "Huila, Colombia"), equals: 2.9, -75.3)
    }

    @Test("Init hydrates every persisted entry at volume")
    func testInit_withManyPersistedEntries_shouldHydrateAll() {
        // Arrange — persist 1_000 distinct origins through one cache.
        let origins = (0..<1_000).map { "origin-\($0)" }
        for (index, origin) in origins.enumerated() {
            sut.save(CLLocationCoordinate2D(latitude: Double(index % 90), longitude: Double(index % 180) - 90), for: origin)
        }

        // Act — a new cache reads them all back from the store on init.
        let rehydrated = UserDefaultsOriginCoordinateCache(store: store)

        // Assert
        for (index, origin) in origins.enumerated() {
            expectCoordinate(rehydrated.coordinate(for: origin), equals: Double(index % 90), Double(index % 180) - 90)
        }
    }
}

private extension OriginCoordinateCacheTests {
    func expectCoordinate(_ actual: CLLocationCoordinate2D?, equals latitude: Double, _ longitude: Double) {
        #expect(actual?.latitude == latitude)
        #expect(actual?.longitude == longitude)
    }
}

final class StubKeyValueStore: KeyValueStore {
    private(set) var writeCount = 0

    private var storage: [String: Any] = [:]

    func dictionary(forKey key: String) -> [String: Any]? {
        storage[key] as? [String: Any]
    }

    func set(_ value: Any?, forKey key: String) {
        writeCount += 1
        storage[key] = value
    }
}
