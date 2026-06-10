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
    
    @Test("Proper initialization")
    func whenInitialized_valuesAreCorrect() {
        #expect(sut.brews.isEmpty)
        #expect(sut.filteredBrews.isEmpty)
        #expect(sut.noResultsText == "Add a brew to get started")
    }
    
    @Test("Brews updated after fetch.")
    func whenBrewsFetched_stateIsUpdated() {
        // Act
        sut.fetchAllBrews()
        
        // Assert
        #expect(!sut.brews.isEmpty)
    }

    // MARK: - Sorting

    @Test("Updating sort to rating descending reorders brew list.")
    func whenUpdatingSortOptionToHighestRated_sortsByRatingDescending() throws {
        // Arrange
        sut.fetchAllBrews()
        
        // Assert
        sortBrewsByHighestRated()
    }

    @Test("Updating sort from highest rated to newest sorts reorders to date descending.")
    func whenUpdatingSortOptionFromHighestRatedToNewest_sortsByDateDescending() {
        // Arrange
        sut.fetchAllBrews()
        
        // Act
        // Confirms sorted by highest rated first
        sortBrewsByHighestRated()
        
        // Sort again by newest
        sut.updateSelectedSortOption(.newest)
        
        // Assert
        let ratings = sut.filteredBrews.map { $0.rating ?? 0 }
        
        #expect(ratings != ratings.sorted(by: >), "Ratings should no longer be in descending order.")
        
        let dates = sut.filteredBrews.map { $0.date }
        #expect(dates == dates.sorted(by: >), "Dates should be in descending order.")
    }

    // MARK: - Searching

    @Test("Empty search query returns all brews.")
    func whenSearchQueryEmpty_returnsAllBrews() {
        // Arrange
        sut.fetchAllBrews()
        
        // Assert
        #expect(sut.filteredBrews.count == sut.brews.count, "Both arrays should be the same length.")
    }

    @Test("Search query filters brews by coffee name")
    func whenSearchQueryUpdated_filtersByCoffeeName() {
        // Arrange
        sut.fetchAllBrews()
        
        // Act
        sut.searchText = "Rodrigo"
        
        // Assert
        #expect(sut.filteredBrews.count == 2, "Should be two matches for search text.")
    }
    
    @Test("No results flag set when no results for search text")
    func whenSearchQueryNotPresent_noResultsShown() {
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
    func sortBrewsByHighestRated() {
        sut.updateSelectedSortOption(.highestRated)
                
        let ratings = sut.filteredBrews.map { $0.rating ?? 0 }
        
        #expect(ratings == ratings.sorted(by: >), "Ratings should be in descending order.")
    }
}
