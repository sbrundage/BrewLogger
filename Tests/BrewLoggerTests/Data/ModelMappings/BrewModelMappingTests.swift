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
        sut.notes = "Tasty"
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
        #expect(result?.notes == "Tasty")
    }

    @Test("toDomain maps rating as nil when not set")
    func testToDomain_whenRatingNotSet_returnsNilRating() {
        let sut = BrewModel(context: context)
        sut.id = UUID().uuidString
        sut.date = Date()
        sut.coffee = makeCoffee()
        #expect(sut.toDomain()?.rating == nil)
    }

    @Test("update(from:) sets all fields from domain model")
    func testUpdateFrom_withAllFields_allFieldsAreSet() {
        // Arrange
        let coffee = Coffee(id: "c1", name: "Test Coffee", originInfo: nil, roastInfo: nil, process: nil)
        let brew = Brew(id: "b1", date: Date(timeIntervalSince1970: 500),
            coffee: coffee, dose: 17.0, yield: 34.0,
            brewTime: 25.0, method: .espresso, rating: 5, notes: "Great")
        let sut = BrewModel(context: context)

        // Act
        sut.update(from: brew)

        // Assert
        #expect(sut.id == "b1")
        #expect(sut.dose == 17.0)
        #expect(sut.yield == 34.0)
        #expect(sut.brewTime == 25.0)
        #expect(sut.method == 2)
        #expect(sut.rating?.doubleValue == 5.0)
        #expect(sut.notes == "Great")
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
