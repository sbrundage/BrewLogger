//
//  BrewRoastDateBackfillTests.swift
//  BrewLogger
//

@testable import BrewLoggerData

import Foundation
import CoreData
import CoreLogger
import Testing

@Suite("BrewRoastDateBackfill")
@MainActor
struct BrewRoastDateBackfillTests {
    let context = PersistenceController.previewBrew.container.viewContext

    @Test("Stamps a nil-roastDate brew from its coffee's roast date")
    func testRun_whenBrewHasNoRoastDate_shouldStampCoffeeRoastDate() throws {
        // Arrange
        let roasted = Date(timeIntervalSince1970: 500_000)
        let brew = makeBrew(coffeeRoastDate: roasted, roastDate: nil)

        // Act
        try BrewRoastDateBackfill.run(in: context)

        // Assert
        #expect(brew.roastDate == roasted)
    }

    @Test("Leaves a brew nil when its coffee has no roast date")
    func testRun_whenCoffeeHasNoRoastDate_shouldLeaveBrewNil() throws {
        // Arrange
        let brew = makeBrew(coffeeRoastDate: nil, roastDate: nil)

        // Act
        try BrewRoastDateBackfill.run(in: context)

        // Assert
        #expect(brew.roastDate == nil)
    }

    @Test("Does not overwrite a brew that already has a roast date")
    func testRun_whenBrewAlreadyHasRoastDate_shouldNotOverwrite() throws {
        // Arrange
        let original = Date(timeIntervalSince1970: 100_000)
        let brew = makeBrew(coffeeRoastDate: Date(timeIntervalSince1970: 999_999), roastDate: original)

        // Act
        try BrewRoastDateBackfill.run(in: context)

        // Assert
        #expect(brew.roastDate == original)
    }
}

private extension BrewRoastDateBackfillTests {
    func makeBrew(coffeeRoastDate: Date?, roastDate: Date?) -> BrewModel {
        let coffee = CoffeeModel(context: context)
        coffee.id = UUID().uuidString
        coffee.name = "Test Coffee"
        coffee.roastDate = coffeeRoastDate

        let brew = BrewModel(context: context)
        brew.id = UUID().uuidString
        brew.date = Date()
        brew.coffee = coffee
        brew.roastDate = roastDate
        return brew
    }
}
