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
        sut.coffeeDraft.name = "Rodrigo Sanchez"
        sut.coffeeDraft.originLocation = "Huila, Colombia"

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
        sut.coffeeDraft.name = "No Origin"

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
            process: nil,
            variety: nil,
            finishedAt: nil
        )
        let geocoding = StubGeocodingService(result: GeocodeResult(latitude: 0, longitude: 0, canonicalName: "Wrong"))
        let sut = SaveCoffeeViewModel(coffeeToEdit: existing, repository: StubCoffeeRepository(), geocoding: geocoding)

        // Act
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.originInfo?.latitude == 2.5359)
        #expect(saved.originInfo?.canonicalName == "Huila, Colombia")
    }

    // MARK: - canSave

    @Test("A new coffee can be saved once it has a name")
    func testCanSave_whenAddingWithName_shouldBeTrue() {
        let sut = makeSUT()
        sut.coffeeDraft.name = "Rodrigo Sanchez"
        #expect(sut.canSave, "Adding must not be blocked by the unchanged-edit check.")
    }

    @Test("A new coffee without a name cannot be saved")
    func testCanSave_whenAddingWithoutName_shouldBeFalse() {
        #expect(!makeSUT().canSave)
    }

    @Test("An untouched edit cannot be saved")
    func testCanSave_whenEditingUnchanged_shouldBeFalse() {
        let sut = makeSUT(editing: fullCoffee())
        #expect(!sut.canSave, "Nothing changed, so there is nothing to save.")
    }

    @Test("Changing a field on an edit enables saving")
    func testCanSave_whenEditingChanged_shouldBeTrue() {
        // Arrange
        let sut = makeSUT(editing: fullCoffee())

        // Act
        sut.coffeeDraft.name = "Renamed"

        // Assert
        #expect(sut.canSave)
    }

    @Test("Reverting an edit back to its original value disables saving again")
    func testCanSave_whenEditRevertedToOriginal_shouldBeFalse() {
        // Arrange
        let sut = makeSUT(editing: fullCoffee())
        let original = sut.coffeeDraft.name

        // Act
        sut.coffeeDraft.name = "Renamed"
        sut.coffeeDraft.name = original

        // Assert
        #expect(!sut.canSave, "Dirty state is a value comparison, not a touched flag.")
    }

    // MARK: - Roast date reactivation

    @Test("Changing the roast date on a finished coffee reopens it")
    func testSaveCoffee_whenFinishedAndRoastDateChanged_shouldReopen() async throws {
        // Arrange
        let sut = makeSUT(editing: fullCoffee(finishedAt: Date(timeIntervalSince1970: 900_000)))

        // Act — a new bag
        sut.coffeeDraft.roastDate = Date(timeIntervalSince1970: 5_000_000)
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.roastInfo?.date == Date(timeIntervalSince1970: 5_000_000))
        #expect(!saved.isFinished, "A new roast date signals a fresh bag, so the coffee reactivates.")
    }

    @Test("Editing other fields on a finished coffee keeps it finished")
    func testSaveCoffee_whenFinishedAndRoastDateUnchanged_shouldStayFinished() async throws {
        // Arrange
        let finished = Date(timeIntervalSince1970: 900_000)
        let sut = makeSUT(editing: fullCoffee(finishedAt: finished))

        // Act
        sut.coffeeDraft.name = "Renamed"
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.finishedAt == finished)
    }

    @Test("Clearing the roast date on a finished coffee reopens it")
    func testSaveCoffee_whenFinishedAndRoastDateCleared_shouldReopen() async throws {
        // Arrange
        let sut = makeSUT(editing: fullCoffee(finishedAt: Date(timeIntervalSince1970: 900_000)))

        // Act
        sut.coffeeDraft.roastDate = nil
        let saved = try await sut.saveCoffee()

        // Assert
        #expect(saved.roastInfo?.date == nil)
        #expect(!saved.isFinished)
    }
}

private extension SaveCoffeeViewModelTests {
    func makeSUT(editing coffee: Coffee? = nil) -> SaveCoffeeViewModel {
        SaveCoffeeViewModel(
            coffeeToEdit: coffee,
            repository: StubCoffeeRepository(),
            geocoding: StubGeocodingService()
        )
    }

    // Every field populated so the draft round-trip is exercised, not just the simple ones.
    func fullCoffee(finishedAt: Date? = nil) -> Coffee {
        Coffee(
            id: "c1",
            name: "Rodrigo Sanchez",
            originInfo: .init(
                location: "Huila, Colombia",
                altitude: 1730,
                latitude: 2.5359,
                longitude: -75.5277,
                canonicalName: "Huila, Colombia"
            ),
            roastInfo: .init(roaster: "KOS", date: Date(timeIntervalSince1970: 1_000_000), roastLevel: .light),
            process: .washed,
            variety: "Pink Bourbon",
            finishedAt: finishedAt
        )
    }
}
