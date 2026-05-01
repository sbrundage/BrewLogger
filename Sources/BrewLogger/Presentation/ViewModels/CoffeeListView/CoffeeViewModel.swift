//
//  CoffeeViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
public class CoffeeViewModel {
    private let fetchCoffees: FetchAllCoffeesUseCase
    private let deleteCoffee: DeleteCoffeeUseCase

    private(set) var coffees: [Coffee] = []

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
