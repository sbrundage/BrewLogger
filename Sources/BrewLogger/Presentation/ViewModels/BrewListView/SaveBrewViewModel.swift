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
    private let fetchAllBrews: FetchAllBrewsUseCase
    
    private var coffees: [Coffee] = []
    
    private(set) var lastBrew: Brew? = nil
    private(set) var justAutofilled = false
    
    var brew = BrewDraft()
    var coffeeSearch = ""

    var canSave: Bool { brew.canSave }
    
    var filteredCoffees: [Coffee] {
        coffeeSearch.isEmpty
            ? coffees
            : coffees.filter { $0.name.localizedCaseInsensitiveContains(coffeeSearch) }
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
        self.fetchAllBrews = FetchAllBrewsUseCase(repository: brewRepository)
        
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
    
    func autofillFromLastBrew() {
        guard
            !isEditing,
            let coffee = brew.coffee,
            let method = brew.method,
            brew.grindSize.isEmpty, // Only autofill when input fields are empty
            brew.dose.isEmpty
        else {
            // TODO: Log
            return
        }
        
        do {
            lastBrew = try fetchAllBrews.execute(coffeeId: coffee.id)
                .first { $0.method == method }

            guard let lastBrew else {
                // TODO: Log - Didn't have first element
                return
            }
            
            // Autofill
            brew.grindSize = String(lastBrew.grindSize)
            brew.dose = String(lastBrew.dose)
            justAutofilled = true
        } catch {
            // TODO: Handle error
            print("[SaveBrewViewModel] - Autofill failed: \(error)")
        }
    }
}

// MARK: Brew Draft Model

extension SaveBrewViewModel {
    struct BrewDraft {
        var id: String? = nil
        // nil until the timer stops (or falls back to save time in convertToBrew).
        var date: Date? = nil
        var coffee: Coffee? = nil
        var grindSize: String = ""
        var dose: String = ""
        var yield: String = ""
        var brewTime: String = ""
        var method: BrewMethod? = nil
        var brewTemp: String = ""
        var rating: String = ""
        var notes: String = ""            // initial-note text (new brews only)
        var tastingEntries: [TastingEntry] = []   // carried through on edit

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
            self.tastingEntries = brew.tastingEntries
        }

        func convertToBrew() -> Brew? {
            guard
                let coffee, let method,
                let grindSize = Double(grindSize),
                let dose = Double(dose),
                let yield = Double(yield),
                let brewTime = Double(brewTime)
            else { return nil }

            let brewDate = date ?? Date()

            // New brew: an initial rating and/or note becomes tasting entry #1 (t=0).
            // Edit: preserve the brew's existing entries untouched.
            let entries: [TastingEntry]
            if id == nil {
                let initialRating = Double(rating)
                entries = (notes.isEmpty && initialRating == nil)
                    ? []
                    : [TastingEntry(createdAt: brewDate, rating: initialRating, note: notes)]
            } else {
                entries = tastingEntries
            }

            return Brew(
                id: id ?? UUID().uuidString,
                date: brewDate,
                coffee: coffee,
                grindSize: grindSize,
                dose: dose,
                yield: yield,
                brewTime: brewTime,
                method: method,
                brewTemp: Int(brewTemp),
                tastingEntries: entries
            )
        }
    }
}
