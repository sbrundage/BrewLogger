//
//  SaveBrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/12/26.
//

import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
final class SaveBrewViewModel {
    private let fetchCoffees: FetchAllCoffeesUseCase
    private let logNewBrew: LogBrewUseCase
    private let updateBrew: UpdateBrewUseCase
    
    private var coffees: [Coffee] = []
    
    var brew = BrewDraft()
    var coffeeSearch = ""

    var canSave: Bool { brew.canSave }
    
    var filteredCoffees: [Coffee] {
        coffeeSearch.isEmpty
        ? coffees
        : coffees.filter { $0.name.localizedCaseInsensitiveContains(coffeeSearch)
        }
    }
    
    var isEditing: Bool { brew.id != nil }

    init(
        brewToEdit: Brew? = nil,
        coffeeRepository: CoffeeRepository = RepositoryFactory.dev.coffee,
        brewRepository: BrewRepository = RepositoryFactory.dev.brew
    ) {
        self.fetchCoffees = FetchAllCoffeesUseCase(repository: coffeeRepository)
        self.logNewBrew = LogBrewUseCase(repository: brewRepository)
        self.updateBrew = UpdateBrewUseCase(repository: brewRepository)
        
        if let brewToEdit {
            self.brew = BrewDraft(from: brewToEdit)
        }
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
            let brew = brew.convertToBrew()
        else { return }
        
        // If we're updating an existing brew, newBrew id will already be set. Otherwise save a new brew
        self.brew.id != nil ?
            try updateBrew.execute(updatedBrew: brew) :
            try logNewBrew.execute(newBrew: brew)
    }
}

extension SaveBrewViewModel {
    struct BrewDraft {
        var id: String? = nil
        var date: Date = Date()
        var coffee: Coffee? = nil
        var grindSize: String = ""
        var dose: String = ""
        var yield: String = ""
        var brewTime: String = ""
        var method: BrewMethod? = nil
        var brewTemp: String = ""
        var rating: String = ""
        var notes: String = ""

        var canSave: Bool {
            coffee != nil &&
            method != nil &&
            Double(grindSize) != nil &&
            Double(dose) != nil &&
            Double(yield) != nil &&
            Double(brewTime) != nil
        }
        
        // for new brews
        init() {}
        
        init(from brew: Brew) {
            self.id = brew.id
            self.date = brew.date
            self.coffee = brew.coffee
            self.grindSize = String(brew.grindSize)
            self.dose = String(brew.dose)
            self.yield = String(brew.yield)
            self.brewTime = String(brew.brewTime)
            self.method = brew.method
            self.brewTemp = brew.brewTemp.map { String($0) } ?? ""
            self.rating = brew.rating.map { String($0) } ?? ""
            self.notes = brew.notes ?? ""
        }

        func convertToBrew() -> Brew? {
            guard
                let coffee, let method,
                let grindSize = Double(grindSize),
                let dose = Double(dose),
                let yield = Double(yield),
                let brewTime = Double(brewTime)
            else { return nil }

            return Brew(
                id: id ?? UUID().uuidString,
                date: date,
                coffee: coffee,
                grindSize: grindSize,
                dose: dose,
                yield: yield,
                brewTime: brewTime,
                method: method,
                brewTemp: Int(brewTemp),
                rating: Double(rating),
                notes: notes.isEmpty ? nil : notes
            )
        }
    }
}
