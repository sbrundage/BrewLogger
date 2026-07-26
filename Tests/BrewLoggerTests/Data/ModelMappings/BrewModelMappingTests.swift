//
//  BrewModelMappingTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/6/26.
//

@testable import BrewLoggerData

import Foundation
import BrewLoggerDomain
import CoreLogger
import Testing

@Suite("BrewModel mapping")
@MainActor
struct BrewModelMappingTests {
    let context = PersistenceController.previewBrew.container.viewContext

    @Test("toDomain returns nil when id is missing")
    func testToDomain_whenIdMissing_shouldReturnNil() {
        let sut = BrewModel(context: context)
        sut.date = Date()
        sut.coffee = makeCoffee()
        #expect(sut.toDomain() == nil)
    }

    @Test("toDomain returns nil when date is missing")
    func testToDomain_whenDateMissing_shouldReturnNil() {
        let sut = BrewModel(context: context)
        sut.id = UUID().uuidString
        sut.coffee = makeCoffee()
        #expect(sut.toDomain() == nil)
    }

    @Test("toDomain returns nil when coffee relationship is missing")
    func testToDomain_whenCoffeeRelationshipIsMissing_shouldReturnNil() {
        let sut = BrewModel(context: context)
        sut.id = UUID().uuidString
        sut.date = Date()
        #expect(sut.toDomain() == nil)
    }

    @Test("toDomain maps all fields correctly")
    func testToDomain_withAllFieldsSet_shouldMapCorrectly() {
        // Arrange
        let coffeeId = UUID().uuidString
        let sut = BrewModel(context: context)
        sut.id = "brew-id"
        sut.date = Date(timeIntervalSince1970: 1000)
        sut.dose = 18.5
        sut.yield = 37.0
        sut.brewTime = 28.0
        sut.method = 1
        sut.rating = NSNumber(value: 4)
        sut.coffee = makeCoffee(id: coffeeId)

        // Act
        let result = sut.toDomain()

        // Assert
        #expect(result?.id == "brew-id")
        #expect(result?.coffee.id == coffeeId)
        #expect(result?.dose == 18.5)
        #expect(result?.yield == 37.0)
        #expect(result?.brewTime == 28.0)
        #expect(result?.method == .pourOver)
        #expect(result?.rating == 4)
    }

    @Test("toDomain decodes stored tasting entries")
    func testToDomain_withTastingEntriesData_shouldDecodeStoredEntries() {
        // Arrange
        let entry = TastingEntry(createdAt: Date(timeIntervalSince1970: 1000), rating: 4.5, note: "Bright")
        let sut = BrewModel(context: context)
        sut.id = "brew-id"
        sut.date = Date()
        sut.coffee = makeCoffee()
        sut.tastingEntriesData = try? JSONEncoder().encode([entry])

        // Act
        let result = sut.toDomain()

        // Assert
        #expect(result?.tastingEntries.count == 1)
        #expect(result?.tastingEntries.first?.note == "Bright")
        #expect(result?.tastingEntries.first?.rating == 4.5)
    }

    @Test("toDomain maps rating as nil when not set")
    func testToDomain_whenRatingNotSet_shouldReturnNilRating() {
        let sut = BrewModel(context: context)
        sut.id = UUID().uuidString
        sut.date = Date()
        sut.coffee = makeCoffee()
        #expect(sut.toDomain()?.rating == nil)
    }

    @Test("update(from:) sets all fields from domain model")
    func testUpdateFrom_withAllFields_shouldSetAllFields() {
        // Arrange
        let coffee = Coffee(id: "coffee-1", name: "Test Coffee", originInfo: nil, roastInfo: nil, process: nil)
        let brew = Brew(id: "brew-1", date: Date(), coffee: coffee, grindSize: 0.5, dose: 17, yield: 34, brewTime: 28, method: .espresso, brewTemp: 195, rating: 5, tastingEntries: [TastingEntry(createdAt: Date(), rating: 5, note: "Great")])
        let sut = BrewModel(context: context)

        // Act
        sut.update(from: brew)

        // Assert
        #expect(sut.id == "brew-1")
        #expect(sut.dose == 17.0)
        #expect(sut.yield == 34.0)
        #expect(sut.brewTime == 28.0)
        #expect(sut.method == 2)
        #expect(sut.rating?.doubleValue == 5.0)
        let entries = try? JSONDecoder().decode([TastingEntry].self, from: sut.tastingEntriesData ?? Data())
        #expect(entries?.first?.note == "Great")
    }

    // MARK: - Legacy notes backfill (remove when the `notes` column is dropped)

    @Test("Legacy notes with no entries backfill to a single entry")
    func testToDomain_withLegacyNotesOnly_shouldBackfillOneEntry() {
        // Arrange
        let sut = BrewModel(context: context)
        sut.id = "brew-id"
        sut.date = Date(timeIntervalSince1970: 1000)
        sut.rating = NSNumber(value: 4)
        sut.notes = "Old note"
        sut.coffee = makeCoffee()
        // no tastingEntriesData

        // Act
        let result = sut.toDomain()

        // Assert
        #expect(result?.tastingEntries.count == 1)
        #expect(result?.tastingEntries.first?.note == "Old note")
        #expect(result?.tastingEntries.first?.rating == 4)
        #expect(result?.tastingEntries.first?.createdAt == Date(timeIntervalSince1970: 1000))
    }

    @Test("Stored entries take precedence over legacy notes")
    func testToDomain_withEntriesAndLegacyNotes_shouldPreferEntries() {
        // Arrange
        let entry = TastingEntry(createdAt: Date(timeIntervalSince1970: 2000), rating: 5, note: "New entry")
        let sut = BrewModel(context: context)
        sut.id = "brew-id"
        sut.date = Date()
        sut.notes = "Legacy note that should be ignored"
        sut.tastingEntriesData = try? JSONEncoder().encode([entry])
        sut.coffee = makeCoffee()

        // Act
        let result = sut.toDomain()

        // Assert
        #expect(result?.tastingEntries.map(\.note) == ["New entry"])
    }
}

private extension BrewModelMappingTests {
    // Helper — brews need a linked coffee to satisfy the coffeeId guard
    func makeCoffee(id: String = UUID().uuidString) -> CoffeeModel {
        let coffee = CoffeeModel(context: context)
        coffee.id = id
        coffee.name = "Test Coffee"
        return coffee
    }
}
