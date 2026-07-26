//
//  BrewTastingFlowTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/26/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerData
import BrewLoggerDomain
import Testing

@Suite("Brew tasting flow")
@MainActor
struct BrewTastingFlowTests {

    private let brewDate = Date(timeIntervalSince1970: 1_000_000)

    @Test("Logging a brew then adding spaced rated notes builds the taste chart")
    func testTastingFlow_addingSpacedRatedNotes_shouldBuildChart() throws {
        // Arrange — log a brew whose initial rating + note become entry #1 at t=0
        let brew = try #require(makeDraft().convertToBrew())
        let sut = BrewDetailsFormView.ViewModel(brew: brew, repository: StubBrewRepository(brews: [brew]))
        #expect(sut.showsChart == false, "One rated entry is not enough to chart")

        // Act — add two more rated notes at 8 and 16 minutes post-brew
        sut.appendEntry(TastingEntry(createdAt: brewDate.addingTimeInterval(8 * 60), rating: 4.5, note: "juicy"))
        sut.appendEntry(TastingEntry(createdAt: brewDate.addingTimeInterval(16 * 60), rating: 3.5, note: "fading"))

        // Assert — three points in order, headline rating is the best of them
        #expect(sut.showsChart)
        #expect(sut.chartPoints.map(\.minutes) == [0, 8, 16])
        #expect(sut.chartPoints.map(\.rating) == [4, 4.5, 3.5])
        #expect(sut.brew.rating == 4.5)
    }
}

private extension BrewTastingFlowTests {
    func makeDraft() -> SaveBrewViewModel.BrewDraft {
        var draft = SaveBrewViewModel.BrewDraft()
        draft.coffee = .preview
        draft.method = .pourOver
        draft.grindSize = "3.5"
        draft.dose = "18"
        draft.yield = "36"
        draft.brewTime = "28"
        draft.date = brewDate
        draft.rating = "4"
        draft.notes = "bright"
        return draft
    }
}
