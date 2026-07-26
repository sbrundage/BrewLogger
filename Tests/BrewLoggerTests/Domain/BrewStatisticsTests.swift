//
//  BrewStatisticsTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/19/26.
//

import Foundation
import BrewLoggerDomain
import Testing

@Suite("Brew+Statistics")
struct BrewStatisticsTests {

    // Fixed calendar so results don't depend on the machine's locale/timezone.
    let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "GMT")!
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }()

    // MARK: - Average rating

    @Test("Average rating ignores brews without a rating")
    func testAverageRating_withMixedNilRatings_shouldAverageOnlyRated() {
        let sut = [
            brew(date: date(2026, 7, 15), rating: 4),
            brew(date: date(2026, 7, 15), rating: nil),
            brew(date: date(2026, 7, 15), rating: 5)
        ]

        #expect(sut.averageRating == 4.5)
    }

    @Test("Average rating is nil when no brew is rated")
    func testAverageRating_whenNoRatings_shouldReturnNil() {
        let sut = [brew(date: date(2026, 7, 15), rating: nil)]

        #expect(sut.averageRating == nil)
    }

    @Test("Average rating is nil for an empty array")
    func testAverageRating_whenEmpty_shouldReturnNil() {
        #expect([Brew]().averageRating == nil)
    }

    // MARK: - Best rating

    @Test("Best rating is the highest rating, ignoring nils")
    func testBestRating_withMixedRatings_shouldReturnHighest() {
        let sut = [
            brew(date: date(2026, 7, 15), rating: 2),
            brew(date: date(2026, 7, 15), rating: nil),
            brew(date: date(2026, 7, 15), rating: 4.5)
        ]

        #expect(sut.bestRating == 4.5)
    }

    @Test("Best rating is nil when no brew is rated")
    func testBestRating_whenNoRatings_shouldReturnNil() {
        let sut = [brew(date: date(2026, 7, 15), rating: nil)]

        #expect(sut.bestRating == nil)
    }

    // MARK: - Per-coffee stats

    @Test("Stats aggregate per coffee id")
    func testStatsByCoffeeId_withMultipleCoffees_shouldAggregatePerCoffee() {
        // Arrange
        let coffeeA = Coffee.previewList[0]
        let coffeeB = Coffee.previewList[1]
        let sut = [
            brew(date: date(2026, 7, 13), rating: 3, coffee: coffeeA),
            brew(date: date(2026, 7, 15), rating: 4, coffee: coffeeA),
            brew(date: date(2026, 7, 14), rating: 5, coffee: coffeeB)
        ]

        // Act
        let stats = sut.statsByCoffeeId()

        // Assert
        #expect(stats[coffeeA.id] == CoffeeBrewStats(
            brewCount: 2, bestRating: 4, lastBrewed: date(2026, 7, 15)
        ))
        #expect(stats[coffeeB.id]?.brewCount == 1)
        #expect(stats["missing-id"] == nil)
    }

    // MARK: - Grouping

    @Test("Grouping by day orders groups newest first with brews newest first")
    func testGroupedByDay_withMultipleDays_shouldOrderNewestFirst() {
        // Arrange
        let sut = [
            brew(date: date(2026, 7, 13, 8)),
            brew(date: date(2026, 7, 15, 7)),
            brew(date: date(2026, 7, 15, 9))
        ]

        // Act
        let groups = sut.groupedByDay(calendar: calendar)

        // Assert
        #expect(groups.count == 2)
        #expect(groups[0].periodStart == date(2026, 7, 15, 0))
        #expect(groups[0].brews.map(\.date) == [date(2026, 7, 15, 9), date(2026, 7, 15, 7)])
        #expect(groups[1].periodStart == date(2026, 7, 13, 0))
    }

    @Test("Grouping an empty array yields no groups")
    func testGroupedByDay_whenEmpty_shouldReturnNoGroups() {
        #expect([Brew]().groupedByDay(calendar: calendar).isEmpty)
    }
}

private extension BrewStatisticsTests {
    func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    func brew(date: Date, rating: Double? = 4, coffee: Coffee = .preview) -> Brew {
        Brew(
            id: UUID().uuidString,
            date: date,
            coffee: coffee,
            grindSize: 0.6,
            dose: 18,
            yield: 36,
            brewTime: 28,
            method: .pourOver,
            brewTemp: 195,
            tastingEntries: rating.map { [TastingEntry(createdAt: date, rating: $0, note: "")] } ?? []
        )
    }
}
