//
//  SaveCoffeeViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/4/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerData
import BrewLoggerDomain
import Testing

@Suite("SaveCoffeeViewModel")
@MainActor
struct SaveCoffeeViewModelTests {

    // MARK: - Geocoding on save

    @Test("Saving a coffee with an origin persists the geocoded coordinate")
    func testSaveCoffee_withOrigin_shouldPersistGeocodedCoordinate() async throws {
        // Arrange
        let geocoding = StubGeocodingService(result: GeocodeResult(latitude: 2.5359, longitude: -75.5277, canonicalName: "Huila, Colombia"))
        let sut = SaveCoffeeViewModel(repository: StubCoffeeRepository(), geocoding: geocoding)
        sut.coffee.name = "Rodrigo Sanchez"
        sut.coffee.originLocation = "Huila, Colombia"

        // Act
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.originInfo?.latitude == 2.5359)
        #expect(saved.originInfo?.longitude == -75.5277)
        #expect(saved.originInfo?.canonicalName == "Huila, Colombia")
    }

    @Test("Saving without an origin does not set a coordinate")
    func testSaveCoffee_withoutOrigin_shouldNotSetCoordinate() async throws {
        // Arrange
        let geocoding = StubGeocodingService(result: GeocodeResult(latitude: 1, longitude: 1, canonicalName: "Somewhere"))
        let sut = SaveCoffeeViewModel(repository: StubCoffeeRepository(), geocoding: geocoding)
        sut.coffee.name = "No Origin"

        // Act
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.originInfo == nil)
    }

    @Test("Editing without changing the origin reuses the stored coordinate")
    func testSaveCoffee_whenOriginUnchanged_shouldReuseStoredCoordinate() async throws {
        // Arrange — a coffee already resolved; geocoder would return a different point if hit.
        let existing = Coffee(
            id: "c1",
            name: "Rodrigo Sanchez",
            originInfo: .init(location: "Huila, Colombia", altitude: 1730, latitude: 2.5359, longitude: -75.5277, canonicalName: "Huila, Colombia"),
            roastInfo: nil,
            process: nil
        )
        let geocoding = StubGeocodingService(result: GeocodeResult(latitude: 0, longitude: 0, canonicalName: "Wrong"))
        let sut = SaveCoffeeViewModel(coffeeToEdit: existing, repository: StubCoffeeRepository(), geocoding: geocoding)

        // Act
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.originInfo?.latitude == 2.5359)
        #expect(saved.originInfo?.canonicalName == "Huila, Colombia")
    }
}
