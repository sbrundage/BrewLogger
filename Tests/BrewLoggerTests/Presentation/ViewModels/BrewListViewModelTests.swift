//
//  BrewListViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/9/26.
//

@testable import BrewLoggerPresentation
import BrewLoggerDomain
import Testing

@Suite("BrewListViewModel")
@MainActor
struct BrewListViewModelTests {

    let sut = BrewListViewModel()

    // MARK: - Initialization

    @Test("Proper initialization")
    func testInit_withNoArguments_shouldHaveDefaultValues() {
        #expect(sut.brews.isEmpty)
        #expect(sut.filteredBrews.isEmpty)
        #expect(sut.noResultsText == "Add a brew to get started")
    }

    // MARK: - Fetch

    @Test("Fetching brews updates state")
    func testFetchAllBrews_whenBrewsExist_shouldUpdateBrews() {
        // Act
        sut.fetchAllBrews()

        // Assert
        #expect(!sut.brews.isEmpty)
    }

    // MARK: - Sections

    @Test("Sections group brews by day, newest first")
    func testSections_withFetchedBrews_shouldGroupByDayNewestFirst() {
        // Arrange
        sut.fetchAllBrews()

        // Act
        let sections = sut.sections

        // Assert
        #expect(sections.count == 5, "Stub brews land on five distinct days.")
        #expect(sections.map(\.periodStart) == sections.map(\.periodStart).sorted(by: >))
        #expect(sections.flatMap(\.brews).count == sut.filteredBrews.count)
    }

    // MARK: - Sorting

    @Test("Updating sort to highest rated reorders brews by rating descending")
    func testUpdateSortOption_toHighestRated_shouldSortByRatingDescending() {
        // Arrange
        sut.fetchAllBrews()

        // Act
        sut.updateSelectedSortOption(.highestRated)

        // Assert
        expectSortedByHighestRated()
    }

    @Test("Updating sort from highest rated to newest reorders brews by date descending")
    func testUpdateSortOption_fromHighestRatedToNewest_shouldSortByDateDescending() {
        // Arrange
        sut.fetchAllBrews()
        sut.updateSelectedSortOption(.highestRated)
        expectSortedByHighestRated()

        // Act
        sut.updateSelectedSortOption(.newest)

        // Assert
        let ratings = sut.filteredBrews.map { $0.rating ?? 0 }
        #expect(ratings != ratings.sorted(by: >), "Ratings should no longer be in descending order.")

        let dates = sut.filteredBrews.map { $0.date }
        #expect(dates == dates.sorted(by: >), "Dates should be in descending order.")
    }

    // MARK: - Searching

    @Test("Empty search query returns all brews")
    func testSearch_whenQueryEmpty_shouldReturnAllBrews() {
        // Arrange
        sut.fetchAllBrews()

        // Assert
        #expect(sut.filteredBrews.count == sut.brews.count, "Both arrays should be the same length.")
    }

    @Test("Search query filters brews by coffee name")
    func testSearch_whenQueryMatchesCoffeeName_shouldFilterBrews() {
        // Arrange
        sut.fetchAllBrews()

        // Act
        sut.searchText = "Rodrigo"

        // Assert
        #expect(sut.filteredBrews.count == 2, "Should be two matches for search text.")
    }

    @Test("No results flag set when search has no matches")
    func testSearch_whenNoMatches_shouldShowNoResults() {
        // Arrange
        sut.fetchAllBrews()

        // Act
        sut.searchText = "randomtext"

        // Assert
        #expect(sut.filteredBrews.count == 0, "Should be no matches for search text.")
        #expect(sut.noResultsText == "No matching results")
    }
}

private extension BrewListViewModelTests {
    func expectSortedByHighestRated() {
        let ratings = sut.filteredBrews.map { $0.rating ?? 0 }
        #expect(ratings == ratings.sorted(by: >), "Ratings should be in descending order.")
    }
}
