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
//    private let originInfoLookup: OriginLookupUseCase
    
    let coffee: Coffee
    
    private(set) var brews: [Brew] = []
    private(set) var highestRatedBrews: [Brew] = []
    
    init(
        repository: BrewRepository = RepositoryFactory.dev.brew,
        coffee: Coffee
    ) {
        self.fetchBrews = FetchAllBrewsUseCase(repository: repository)
        self.coffee = coffee
    }
    
    func fetchAllBrews() async {
        do {
            self.brews = try fetchBrews.execute(coffeeId: coffee.id)
            setupBrewStats()
        } catch {
            // TODO: Handle errors
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
