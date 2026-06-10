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

    private var coffees: [Coffee] = []
    
    // Func that returns array or a didSet that sets this variable
    var displayedCoffees: [Coffee] { filterBySearchText() }
    
    var noSearchResults: Bool {
        !coffees.isEmpty && displayedCoffees.isEmpty
    }
    
    var noResultsText: String {
        noSearchResults ? "No matching results" : "Add a coffee to get started"
    }

    var searchText: String = ""
    var showAddCoffeeSheet: Bool = false

    public init(
        repository: CoffeeRepository = RepositoryFactory.dev.coffee
    ) {
        self.fetchCoffees = FetchAllCoffeesUseCase(repository: repository)
        self.deleteCoffee = DeleteCoffeeUseCase(repository: repository)
    }

    func fetchAllCoffees() {
        do {
            self.coffees = try fetchCoffees.execute()
        } catch {}
    }

    func delete(_ coffee: Coffee) {
        do {
            try deleteCoffee.execute(coffeeId: coffee.id)
            fetchAllCoffees()
        } catch {}
    }
}

private extension CoffeeListViewModel {
    func filterBySearchText() -> [Coffee] {
        guard !searchText.isEmpty else { return coffees }
        return coffees.filter {
            $0.isMatch(for: searchText.lowercased())
        }
    }
}
