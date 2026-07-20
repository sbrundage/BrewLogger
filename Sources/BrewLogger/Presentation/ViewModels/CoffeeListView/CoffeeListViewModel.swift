//
//  CoffeeListViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
public class CoffeeListViewModel {
    private let fetchCoffees: FetchAllCoffeesUseCase
    private let deleteCoffee: DeleteCoffeeUseCase
    private let fetchBrews: FetchAllBrewsUseCase

    private var coffees: [Coffee] = []
    private var statsByCoffeeId: [String: CoffeeBrewStats] = [:]

    private(set) var selectedSortOption: CoffeeSortOption = .recentlyBrewed

    // Func that returns array or a didSet that sets this variable
    var displayedCoffees: [Coffee] { sorted(filterBySearchText()) }

    var noSearchResults: Bool {
        !coffees.isEmpty && displayedCoffees.isEmpty
    }

    var noResultsText: String {
        noSearchResults ? "No matching results" : "Add a coffee to get started"
    }

    var searchText: String = ""
    var showAddCoffeeSheet: Bool = false

    public init(
        repository: CoffeeRepository = RepositoryFactory.dev.coffee,
        brewRepository: BrewRepository = RepositoryFactory.dev.brew
    ) {
        self.fetchCoffees = FetchAllCoffeesUseCase(repository: repository)
        self.deleteCoffee = DeleteCoffeeUseCase(repository: repository)
        self.fetchBrews = FetchAllBrewsUseCase(repository: brewRepository)
    }

    func fetchAllCoffees() {
        do {
            self.coffees = try fetchCoffees.execute()
            let brews = try fetchBrews.execute(coffeeId: nil)
            self.statsByCoffeeId = brews.statsByCoffeeId()
        } catch {}
    }

    func delete(_ coffee: Coffee) {
        do {
            try deleteCoffee.execute(coffeeId: coffee.id)
            fetchAllCoffees()
        } catch {}
    }

    func stats(for coffee: Coffee) -> CoffeeBrewStats? {
        statsByCoffeeId[coffee.id]
    }

    func updateSelectedSortOption(_ option: CoffeeSortOption) {
        self.selectedSortOption = option
    }
}

private extension CoffeeListViewModel {
    func filterBySearchText() -> [Coffee] {
        guard !searchText.isEmpty else { return coffees }
        return coffees.filter {
            $0.isMatch(for: searchText)
        }
    }

    func sorted(_ coffees: [Coffee]) -> [Coffee] {
        switch selectedSortOption {
        case .recentlyBrewed:
            sortedDescendingNilsLast(coffees) { stats(for: $0)?.lastBrewed }
        case .mostBrewed:
            coffees.sorted { (stats(for: $0)?.brewCount ?? 0) > (stats(for: $1)?.brewCount ?? 0) }
        case .highestRated:
            sortedDescendingNilsLast(coffees) { stats(for: $0)?.bestRating }
        case .freshestRoast:
            sortedDescendingNilsLast(coffees) { $0.roastInfo?.date }
        }
    }

    func sortedDescendingNilsLast<Value: Comparable>(
        _ coffees: [Coffee],
        by value: (Coffee) -> Value?
    ) -> [Coffee] {
        coffees.sorted {
            switch (value($0), value($1)) {
            case let (lhs?, rhs?): lhs > rhs
            case (_?, nil): true
            default: false
            }
        }
    }
}
