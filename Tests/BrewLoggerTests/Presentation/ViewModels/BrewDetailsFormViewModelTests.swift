//
//  BrewDetailsFormViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/21/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerData
import BrewLoggerDomain
import Testing

@Suite("BrewDetailsFormView.ViewModel")
@MainActor
struct BrewDetailsFormViewModelTests {

    private func brew(
        rating: Double? = nil,
        brewTemp: Int? = 195,
        tastingEntries: [TastingEntry] = [],
        coffee: Coffee = .preview
    ) -> Brew {
        var entries = tastingEntries
        if entries.isEmpty, let rating {
            entries = [TastingEntry(createdAt: Date(timeIntervalSince1970: 1_000_000), rating: rating, note: "")]
        }
        return Brew(
            id: "brew-1",
            date: Date(timeIntervalSince1970: 1_000_000),
            coffee: coffee,
            grindSize: 3.5,
            dose: 18,
            yield: 36,
            brewTime: 28,
            method: .pourOver,
            brewTemp: brewTemp,
            tastingEntries: entries
        )
    }

    private func sut(_ brew: Brew) -> BrewDetailsFormView.ViewModel {
        BrewDetailsFormView.ViewModel(brew: brew, repository: StubBrewRepository(brews: [brew]))
    }

    // MARK: - Brew info rows

    @Test("Brew info includes rating and temp when present")
    func testBrewInfoRows_whenRatingAndTempPresent_shouldIncludeAllRows() {
        let rows = sut(brew(rating: 4)).brewInfoRows
        #expect(rows.map(\.label) == ["Grind Size", "Time", "Yield", "Method", "Rating", "Temp"])
        #expect(rows.map(\.value) == ["3.5", "28s", "36.0g", "Pour Over", "4.0 ★", "195°F"])
    }

    @Test("Brew info omits rating and temp when nil")
    func testBrewInfoRows_whenRatingAndTempNil_shouldOmitThoseRows() {
        let rows = sut(brew(brewTemp: nil)).brewInfoRows
        #expect(rows.map(\.label) == ["Grind Size", "Time", "Yield", "Method"])
    }

    // MARK: - Roast info rows

    @Test("Roast info is empty when the coffee has no roast info")
    func testRoastInfoRows_whenNoRoastInfo_shouldReturnEmpty() {
        let coffee = Coffee(id: "c", name: "X", originInfo: nil, roastInfo: nil, process: nil)
        #expect(sut(brew(coffee: coffee)).roastInfoRows.isEmpty)
    }

    @Test("Roast info includes only the present fields")
    func testRoastInfoRows_withPartialRoastInfo_shouldIncludeOnlyPresent() {
        let coffee = Coffee(
            id: "c", name: "X", originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: nil, roastLevel: nil),
            process: nil
        )
        let rows = sut(brew(coffee: coffee)).roastInfoRows
        #expect(rows.map(\.label) == ["Roaster"])
        #expect(rows.first?.value == "KOS")
    }

    // MARK: - Entry rows

    @Test("Entry rows are sorted chronologically with derived time labels")
    func testEntryRows_withEntries_shouldSortAndLabel() {
        // Arrange — brew date is 1_000_000; entries at +0 and +8 min, out of order
        let brewDate = Date(timeIntervalSince1970: 1_000_000)
        let entries = [
            TastingEntry(createdAt: brewDate.addingTimeInterval(8 * 60), rating: 3.5, note: "fading"),
            TastingEntry(createdAt: brewDate, rating: 4.5, note: "bright")
        ]

        // Act
        let rows = sut(brew(tastingEntries: entries)).entryRows

        // Assert
        #expect(rows.map(\.note) == ["bright", "fading"])
        #expect(rows.first?.timeLabel == "At brew")
        #expect(rows.last?.timeLabel == "8 min post-brew")
    }

    @Test("No entries yields no rows")
    func testEntryRows_whenEmpty_shouldReturnNoRows() {
        #expect(sut(brew(tastingEntries: [])).entryRows.isEmpty)
    }

    @Test("Out-of-window entries have no time label")
    func testEntryRows_whenOutOfWindow_shouldHaveNilTimeLabel() {
        let brewDate = Date(timeIntervalSince1970: 1_000_000)
        let entry = TastingEntry(createdAt: brewDate.addingTimeInterval(120 * 60), rating: nil, note: "later")

        #expect(sut(brew(tastingEntries: [entry])).entryRows.first?.timeLabel == nil)
    }

    // MARK: - Chart

    @Test("Chart points include only rated entries")
    func testChartPoints_withMixedRatings_shouldIncludeOnlyRated() {
        let brewDate = Date(timeIntervalSince1970: 1_000_000)
        let entries = [
            TastingEntry(createdAt: brewDate, rating: 4, note: "a"),
            TastingEntry(createdAt: brewDate.addingTimeInterval(60), rating: nil, note: "no rating"),
            TastingEntry(createdAt: brewDate.addingTimeInterval(120), rating: 3, note: "c")
        ]

        let points = sut(brew(tastingEntries: entries)).chartPoints

        #expect(points.map(\.rating) == [4, 3])
    }

    @Test("Chart shows with at least two rated entries")
    func testShowsChart_withTwoRatedEntries_shouldReturnTrue() {
        let brewDate = Date(timeIntervalSince1970: 1_000_000)
        let entries = [
            TastingEntry(createdAt: brewDate, rating: 4, note: "a"),
            TastingEntry(createdAt: brewDate.addingTimeInterval(60), rating: 3, note: "b")
        ]

        #expect(sut(brew(tastingEntries: entries)).showsChart)
    }

    @Test("Chart hidden with fewer than two rated entries")
    func testShowsChart_withOneRatedEntry_shouldReturnFalse() {
        let entry = TastingEntry(createdAt: Date(timeIntervalSince1970: 1_000_000), rating: 4, note: "a")

        #expect(!sut(brew(tastingEntries: [entry])).showsChart)
    }

    @Test("Chart excludes entries outside the session window")
    func testChartPoints_withOutOfWindowEntry_shouldExcludeIt() {
        let brewDate = Date(timeIntervalSince1970: 1_000_000)
        let entries = [
            TastingEntry(createdAt: brewDate, rating: 4, note: "in window"),
            TastingEntry(createdAt: brewDate.addingTimeInterval(120 * 60), rating: 3, note: "hours later")
        ]

        #expect(sut(brew(tastingEntries: entries)).chartPoints.map(\.rating) == [4])
    }

    // MARK: - Append entry

    @Test("Appending an entry adds it to the brew")
    func testAppendEntry_whenNoExisting_shouldAddEntry() {
        let vm = sut(brew(tastingEntries: []))

        vm.appendEntry(TastingEntry(createdAt: Date(), rating: 4, note: "bright"))

        #expect(vm.brew.tastingEntries.map(\.note) == ["bright"])
    }

    @Test("Appending keeps existing entries in order")
    func testAppendEntry_withExisting_shouldAppendAfter() {
        let existing = TastingEntry(createdAt: Date(), rating: 4, note: "first")
        let vm = sut(brew(tastingEntries: [existing]))

        vm.appendEntry(TastingEntry(createdAt: Date(), rating: 3, note: "second"))

        #expect(vm.brew.tastingEntries.map(\.note) == ["first", "second"])
    }

    // MARK: - Passthrough

    @Test("Title and brew date pass through from the brew")
    func testTitleAndBrewDate_shouldMatchBrew() {
        let b = brew()
        let vm = sut(b)
        #expect(vm.title == b.coffee.name)
        #expect(vm.brewDate == b.date)
    }
}
