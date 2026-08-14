//
//  CoffeeListViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/19/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerData
import BrewLoggerDomain
import Testing

@Suite("CoffeeListViewModel")
@MainActor
struct CoffeeListViewModelTests {

    // Fresh stub instances per test so mutations never leak into the shared
    // stub factory other suites rely on. Stub data: Coffee.previewList /
    // Brew.previewList, where coffees 0–2 have 2 / 2 / 1 brews with ratings
    // (4, 3) / (5, 4) / (3).
    let sut = CoffeeListViewModel(
        repository: StubCoffeeRepository(),
        brewRepository: StubBrewRepository()
    )

    // MARK: - Initialization

    @Test("Proper initialization")
    func testInit_withDefaults_shouldHaveDefaultValues() {
        #expect(sut.displayedCoffees.isEmpty)
        #expect(sut.selectedSortOption == .recentlyBrewed)
        #expect(sut.noResultsText == "Add a coffee to get started")
    }

    // MARK: - Stats aggregation

    @Test("Fetching builds per-coffee brew stats")
    func testFetchAllCoffees_whenBrewsExist_shouldAggregateStatsPerCoffee() {
        // Act
        sut.fetchAllCoffees()

        // Assert
        let rodrigo = sut.displayedCoffees.first { $0.name == "Rodrigo Sanchez" }!
        let stats = sut.stats(for: rodrigo)
        #expect(stats?.brewCount == 2)
        #expect(stats?.bestRating == 4)
        #expect(stats?.lastBrewed != nil)
    }

    @Test("Coffees without brews have no stats")
    func testStats_forCoffeeWithoutBrews_shouldReturnNil() {
        // Act
        sut.fetchAllCoffees()

        // Assert
        let unbrewed = sut.displayedCoffees.first { $0.name == "Drop Bear Espresso" }!
        #expect(sut.stats(for: unbrewed) == nil)
    }

    // MARK: - Sorting

    @Test("Recently brewed sort puts most recent coffees first, unbrewed last")
    func testSort_withRecentlyBrewed_shouldOrderByLastBrewedDescending() {
        // Act
        sut.fetchAllCoffees()

        // Assert
        let names = sut.displayedCoffees.map(\.name)
        #expect(Array(names.prefix(3)) == ["Rodrigo Sanchez", "El Puente", "Guatemala"])
        #expect(sut.stats(for: sut.displayedCoffees.last!) == nil, "Unbrewed coffees should sort last.")
    }

    @Test("Most brewed sort orders by brew count descending")
    func testSort_withMostBrewed_shouldOrderByBrewCountDescending() {
        // Arrange
        sut.fetchAllCoffees()

        // Act
        sut.updateSelectedSortOption(.mostBrewed)

        // Assert
        let topTwo = Set(sut.displayedCoffees.prefix(2).map(\.name))
        #expect(topTwo == ["Rodrigo Sanchez", "El Puente"], "Both have two brews.")
        #expect(sut.stats(for: sut.displayedCoffees[2])?.brewCount == 1)
    }

    @Test("Highest rated sort orders by best brew rating descending")
    func testSort_withHighestRated_shouldOrderByBestRatingDescending() {
        // Arrange
        sut.fetchAllCoffees()

        // Act
        sut.updateSelectedSortOption(.highestRated)

        // Assert
        let names = sut.displayedCoffees.map(\.name)
        #expect(Array(names.prefix(3)) == ["El Puente", "Rodrigo Sanchez", "Guatemala"])
    }

    @Test("Freshest roast sort puts coffees without a roast date last")
    func testSort_withFreshestRoast_shouldPutNilRoastDatesLast() {
        // Arrange
        sut.fetchAllCoffees()

        // Act
        sut.updateSelectedSortOption(.freshestRoast)

        // Assert
        let withoutRoastDate = Set(sut.displayedCoffees.suffix(3).map(\.name))
        #expect(withoutRoastDate == ["El Puente", "Koke Washing Station", "Drop Bear Espresso"])
        #expect(sut.displayedCoffees.first?.roastInfo?.date != nil)
    }

    // MARK: - Searching

    @Test("Search query filters coffees by name")
    func testSearch_whenQueryMatchesName_shouldFilterCoffees() {
        // Arrange
        sut.fetchAllCoffees()

        // Act
        sut.searchText = "Rodrigo"

        // Assert
        #expect(sut.displayedCoffees.count == 1)
    }

    @Test("No results text updates when search has no matches")
    func testSearch_whenNoMatches_shouldShowNoResults() {
        // Arrange
        sut.fetchAllCoffees()

        // Act
        sut.searchText = "randomtext"

        // Assert
        #expect(sut.displayedCoffees.isEmpty)
        #expect(sut.noResultsText == "No matching results")
    }

    // MARK: - Deleting

    @Test("Deleting a coffee removes it from state")
    func testDelete_withExistingCoffee_shouldRemoveCoffee() {
        // Arrange
        sut.fetchAllCoffees()
        let coffee = sut.displayedCoffees[0]

        // Act
        sut.delete(coffee)

        // Assert
        #expect(!sut.displayedCoffees.contains { $0.id == coffee.id })
    }

    // MARK: - Finished toggle

    @Test("Marking an active coffee finished flags it")
    func testToggleFinished_whenActive_shouldMarkFinished() {
        // Arrange
        sut.fetchAllCoffees()
        let coffee = sut.displayedCoffees.first { !$0.isFinished }!

        // Act
        sut.toggleFinished(coffee)

        // Assert
        #expect(sut.displayedCoffees.first { $0.id == coffee.id }?.isFinished == true)
    }

    @Test("Toggling a finished coffee reopens it")
    func testToggleFinished_whenFinished_shouldReopen() {
        // Arrange
        sut.fetchAllCoffees()
        let coffee = sut.displayedCoffees[0]
        sut.toggleFinished(coffee)
        let finished = sut.displayedCoffees.first { $0.id == coffee.id }!

        // Act
        sut.toggleFinished(finished)

        // Assert
        #expect(sut.displayedCoffees.first { $0.id == coffee.id }?.isFinished == false)
    }

    // MARK: - Delete message

    @Test("Delete message counts the coffee's logged brews")
    func testDeleteMessage_withBrews_shouldCountThem() {
        sut.fetchAllCoffees()
        let rodrigo = sut.displayedCoffees.first { $0.name == "Rodrigo Sanchez" }!
        #expect(sut.deleteMessage(for: rodrigo) == "This also deletes 2 logged brews.")
    }

    @Test("Delete message uses singular for a single brew")
    func testDeleteMessage_withOneBrew_shouldUseSingular() {
        sut.fetchAllCoffees()
        let guatemala = sut.displayedCoffees.first { $0.name == "Guatemala" }!
        #expect(sut.deleteMessage(for: guatemala) == "This also deletes 1 logged brew.")
    }

    @Test("Delete message omits the count when there are no brews")
    func testDeleteMessage_withNoBrews_shouldOmitCount() {
        sut.fetchAllCoffees()
        let dropBear = sut.displayedCoffees.first { $0.name == "Drop Bear Espresso" }!
        #expect(sut.deleteMessage(for: dropBear) == "This can't be undone.")
    }
}
