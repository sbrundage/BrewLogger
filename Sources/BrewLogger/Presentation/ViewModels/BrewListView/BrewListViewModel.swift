//
//  BrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/9/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

// TODO: Thought - How much of repetitive logic in the VM could we meaningfully extract?
// Both List VMs have the same functionality just different models
// Could possible explore extracting using protocols and composing vms with their appropriate boilerplate code

@MainActor @Observable
class BrewListViewModel {
    private let fetchBrews: FetchAllBrewsUseCase
    private let deleteBrew: DeleteBrewUseCase
    
    private var noSearchResults: Bool {
        !brews.isEmpty && filteredBrews.isEmpty
    }

    private(set) var brews: [Brew] = []
    
    // Why not just a var?
    // Rather than exposing function to adjust this value - what's the benefit
    private(set) var selectedSortOption: BrewSortOption = .newest {
        didSet { sortBrews() }
    }
    
    var filteredBrews: [Brew] { filterBySearchText() }

    // Day-grouped for the list; the view flattens these when sorted by rating.
    var sections: [BrewDateGroup] { filteredBrews.groupedByDay() }

    func sectionTitle(for periodStart: Date) -> String {
        if Calendar.current.isDateInToday(periodStart) { return "Today" }
        if Calendar.current.isDateInYesterday(periodStart) { return "Yesterday" }
        return periodStart.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }
    
    var noResultsText: String {
        noSearchResults ? "No matching results" : "Add a brew to get started"
    }
    
    var searchText: String = ""
    var showAddBrewSheet: Bool = false
    
    init(
        repository: BrewRepository = RepositoryFactory.dev.brew,
        sortOption: BrewSortOption = .newest
    ) {
        self.fetchBrews = FetchAllBrewsUseCase(repository: repository)
        self.deleteBrew = DeleteBrewUseCase(repository: repository)
        self.selectedSortOption = sortOption
    }

    func fetchAllBrews() {
        do {
            self.brews = try fetchBrews.execute(coffeeId: nil)
            sortBrews()
        } catch {
            // TODO: Handle error
            print("Failed to fetch brews: \(error)")
        }
    }
    
    func delete(_ brew: Brew) {
        do {
            try deleteBrew.execute(brewId: brew.id)
            brews.removeAll { $0.id == brew.id }
        } catch {
            // TODO: Handle error
            print("Failed to delete brew: \(error)")
        }
    }
    
    func updateSelectedSortOption(_ option: BrewSortOption) {
        self.selectedSortOption = option
    }
}

private extension BrewListViewModel {
    func sortBrews() {
        switch selectedSortOption {
        case .highestRated:
            self.brews = brews.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
        case .newest:
            self.brews = brews.sorted { $0.date > $1.date }
        }
    }
    
    // Could extract this out into a static func on Brew array?
    // Both List VMs have the same functionality and we could extract out and then have tests
    func filterBySearchText() -> [Brew] {
        guard !searchText.isEmpty else { return brews }
        return brews.filter {
            $0.isMatch(for: searchText)
        }
    }
}

