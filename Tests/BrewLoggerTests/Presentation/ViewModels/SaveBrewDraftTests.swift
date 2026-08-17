//
//  SaveBrewDraftTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/21/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerDomain
import Testing

@Suite("SaveBrewViewModel.BrewDraft")
struct SaveBrewDraftTests {

    // MARK: - Date stamping

    @Test("Converting with no date stamps the current time")
    func testConvertToBrew_whenDateNil_shouldStampNow() throws {
        // Arrange
        var draft = validDraft()
        draft.date = nil

        // Act
        let before = Date()
        let brew = try #require(draft.convertToBrew())
        let after = Date()

        // Assert
        #expect(brew.date >= before && brew.date <= after)
    }

    @Test("Converting preserves an explicitly set date")
    func testConvertToBrew_whenDateSet_shouldPreserveIt() throws {
        // Arrange
        let stopped = Date(timeIntervalSince1970: 1_000_000)
        var draft = validDraft()
        draft.date = stopped

        // Act
        let brew = try #require(draft.convertToBrew())

        // Assert
        #expect(brew.date == stopped)
    }

    @Test("A draft built from an existing brew keeps that brew's date")
    func testInitFromBrew_shouldPreserveBrewDate() throws {
        // Arrange
        let original = brew(date: Date(timeIntervalSince1970: 2_000_000))
        let draft = SaveBrewViewModel.BrewDraft(from: original)

        // Act
        let converted = try #require(draft.convertToBrew())

        // Assert
        #expect(converted.date == original.date)
    }

    // MARK: - Roast date snapshot

    @Test("Converting with no roast date snapshots the coffee's current roast date")
    func testConvertToBrew_whenRoastDateNil_shouldSnapshotCoffeeRoastDate() throws {
        // Arrange
        let roasted = Date(timeIntervalSince1970: 500_000)
        var draft = validDraft()
        draft.coffee = coffee(roastDate: roasted)
        draft.roastDate = nil

        // Act
        let brew = try #require(draft.convertToBrew())

        // Assert
        #expect(brew.roastDate == roasted)
    }

    @Test("Converting preserves an explicitly set roast date over the coffee's")
    func testConvertToBrew_whenRoastDateSet_shouldPreserveIt() throws {
        // Arrange
        let picked = Date(timeIntervalSince1970: 900_000)
        var draft = validDraft()
        draft.coffee = coffee(roastDate: Date(timeIntervalSince1970: 500_000))
        draft.roastDate = picked

        // Act
        let brew = try #require(draft.convertToBrew())

        // Assert
        #expect(brew.roastDate == picked)
    }

    @Test("A draft built from an existing brew keeps that brew's roast date")
    func testInitFromBrew_shouldPreserveRoastDate() throws {
        // Arrange
        let roasted = Date(timeIntervalSince1970: 700_000)
        let original = brew(date: Date(), roastDate: roasted)
        let draft = SaveBrewViewModel.BrewDraft(from: original)

        // Act
        let converted = try #require(draft.convertToBrew())

        // Assert
        #expect(converted.roastDate == roasted)
    }
}

private extension SaveBrewDraftTests {
    func validDraft() -> SaveBrewViewModel.BrewDraft {
        var draft = SaveBrewViewModel.BrewDraft()
        draft.coffee = .preview
        draft.method = .pourOver
        draft.grindSize = "3.5"
        draft.dose = "18"
        draft.yield = "36"
        draft.brewTime = "28"
        return draft
    }

    func brew(date: Date, roastDate: Date? = nil) -> Brew {
        Brew(
            id: "brew-1",
            date: date,
            coffee: .preview,
            grindSize: 3.5,
            dose: 18,
            yield: 36,
            brewTime: 28,
            method: .pourOver,
            brewTemp: 195,
            roastDate: roastDate,
            tastingEntries: []
        )
    }

    func coffee(roastDate: Date?) -> Coffee {
        Coffee(
            id: "c",
            name: "X",
            originInfo: nil,
            roastInfo: .init(roaster: nil, date: roastDate, roastLevel: nil),
            process: nil,
            variety: nil,
            finishedAt: nil
        )
    }
}
