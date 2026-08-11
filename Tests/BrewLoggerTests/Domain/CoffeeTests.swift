//
//  CoffeeTests.swift
//  BrewLogger
//

@testable import BrewLoggerDomain

import Foundation
import Testing

@Suite("Coffee")
struct CoffeeTests {

    // MARK: - markingFinished

    @Test("Marking finished sets the timestamp and flags the coffee finished")
    func testMarkingFinished_withDate_shouldBeFinished() {
        // Arrange
        let finished = Date(timeIntervalSince1970: 1000)
        let sut = coffee(finishedAt: nil)

        // Act
        let result = sut.markingFinished(finished)

        // Assert
        #expect(result.finishedAt == finished)
        #expect(result.isFinished)
    }

    @Test("Marking finished with nil reopens the coffee")
    func testMarkingFinished_withNil_shouldReopen() {
        // Arrange
        let sut = coffee(finishedAt: Date(timeIntervalSince1970: 1000))

        // Act
        let result = sut.markingFinished(nil)

        // Assert
        #expect(result.finishedAt == nil)
        #expect(!result.isFinished)
    }

    // MARK: - openingBag

    @Test("Opening a bag stamps the new roast date and keeps roaster and level")
    func testOpeningBag_withExistingRoastInfo_shouldUpdateDateKeepingRest() {
        // Arrange
        let sut = coffee(roastInfo: RoastInfo(roaster: "KOS", date: Date(timeIntervalSince1970: 0), roastLevel: .light))
        let newDate = Date(timeIntervalSince1970: 500_000)

        // Act
        let result = sut.openingBag(roastedAt: newDate)

        // Assert
        #expect(result.roastInfo?.date == newDate)
        #expect(result.roastInfo?.roaster == "KOS")
        #expect(result.roastInfo?.roastLevel == .light)
    }

    @Test("Opening a bag creates roast info when the coffee had none")
    func testOpeningBag_withNoRoastInfo_shouldCreateItWithTheDate() {
        // Arrange
        let sut = coffee(roastInfo: nil)
        let newDate = Date(timeIntervalSince1970: 500_000)

        // Act
        let result = sut.openingBag(roastedAt: newDate)

        // Assert
        #expect(result.roastInfo?.date == newDate)
        #expect(result.roastInfo?.roaster == nil)
    }

    @Test("Opening a bag reactivates a finished coffee")
    func testOpeningBag_whenFinished_shouldReopen() {
        // Arrange
        let sut = coffee(finishedAt: Date(timeIntervalSince1970: 1000))

        // Act
        let result = sut.openingBag(roastedAt: Date(timeIntervalSince1970: 500_000))

        // Assert
        #expect(!result.isFinished)
    }
}

private extension CoffeeTests {
    func coffee(roastInfo: RoastInfo? = nil, finishedAt: Date? = nil) -> Coffee {
        Coffee(
            id: "c",
            name: "X",
            originInfo: nil,
            roastInfo: roastInfo,
            process: nil,
            variety: nil,
            finishedAt: finishedAt
        )
    }
}
