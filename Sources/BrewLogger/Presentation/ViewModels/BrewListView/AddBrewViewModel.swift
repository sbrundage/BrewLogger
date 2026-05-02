//
//  AddBrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
final class AddBrewViewModel {
    private let fetchCoffees: FetchAllCoffeesUseCase
    private let logNewCoffee: LogCoffeeUseCase
    private let logNewBrew: LogBrewUseCase
    
    private var coffees: [Coffee] = []
    
    var newBrew = NewBrew()
    var coffeeSearch = ""

    var canSave: Bool { newBrew.canSave }
    
    var filteredCoffees: [Coffee] {
        coffeeSearch.isEmpty
        ? coffees
        : coffees.filter { $0.name.localizedCaseInsensitiveContains(coffeeSearch)
        }
    }
    
    init(
        coffeeRepository: CoffeeRepository = RepositoryFactory.dev.coffee,
        brewRepository: BrewRepository = RepositoryFactory.dev.brew
    ) {
        self.logNewCoffee = LogCoffeeUseCase(repository: coffeeRepository)
        self.fetchCoffees = FetchAllCoffeesUseCase(repository: coffeeRepository)
        self.logNewBrew = LogBrewUseCase(repository: brewRepository)
    }
    
    func fetchAllCoffees() {
        do {
            coffees = try fetchCoffees.execute()
        } catch {
            // TODO: Handle Error
            print("Got an error while fetching all coffees: \(error)")
        }
    }
    
    func saveBrew() throws {
        // TODO: Handle error / show pop up
        guard
            canSave,
            let newBrew = newBrew.convertToBrew()
        else { return }
        
        try logNewBrew.execute(newBrew: newBrew)
    }
}

extension AddBrewViewModel {
    struct NewBrew {
        var coffee: Coffee? = nil
        var dose: String = ""
        var yield: String = ""
        var brewTime: String = ""
        var method: BrewMethod? = nil
        var rating: String = ""
        var notes: String = ""

        var canSave: Bool {
            coffee != nil &&
            method != nil &&
            Double(dose) != nil &&
            Double(yield) != nil &&
            Double(brewTime) != nil
        }

        func convertToBrew() -> Brew? {
            guard
                let coffee, let method,
                let dose = Double(dose),
                let yield = Double(yield),
                let brewTime = Double(brewTime)
            else { return nil }

            return Brew(
                date: Date(),
                coffee: coffee,
                dose: dose,
                yield: yield,
                brewTime: brewTime,
                method: method,
                rating: Double(rating),
                notes: notes.isEmpty ? nil : notes
            )
        }
    }
}
