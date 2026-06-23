//
//  CoffeeDetailsViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/20/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor
@Observable
final class CoffeeDetailsViewModel {
    private let fetchBrews: FetchAllBrewsUseCase
    private let fetchCoffee: FetchCoffeeUseCase
//    private let originInfoLookup: OriginLookupUseCase
    
    private(set) var coffee: Coffee
    
    private(set) var brews: [Brew] = []
    private(set) var highestRatedBrews: [Brew] = []
    
    init(
        brewRepository: BrewRepository = RepositoryFactory.dev.brew,
        coffeeRepository: CoffeeRepository = RepositoryFactory.dev.coffee,
        coffee: Coffee
    ) {
        self.fetchBrews = FetchAllBrewsUseCase(repository: brewRepository)
        self.fetchCoffee = FetchCoffeeUseCase(repository: coffeeRepository)
        self.coffee = coffee
    }
    
    func fetchAllBrews() {
        do {
            self.brews = try fetchBrews.execute(coffeeId: coffee.id)
            setupBrewStats()
        } catch {
            // TODO: Handle errors
        }
    }
    
    func refetchCoffee() {
        do {
            guard let updatedCoffee = try fetchCoffee.execute(coffeeId: coffee.id) else {
                // TODO: Handle failure
                return
            }
            self.coffee = updatedCoffee
        } catch {
            // TODO: Handle error
        }
    }
}

private extension CoffeeDetailsViewModel {
    func setupBrewStats() {
        guard !brews.isEmpty else { return }
        
        let highestRatedBrews = brews.sorted { $0.rating ?? 0 > $1.rating ?? 0 }
        let highestRatedEspresso = highestRatedBrews.first { $0.method == .espresso }
        let highestRatedPourOver = highestRatedBrews.first { $0.method == .pourOver }
        
        let highestRated: [Brew] = [highestRatedEspresso, highestRatedPourOver].compactMap { $0 }
        self.highestRatedBrews = highestRated
    }
}
