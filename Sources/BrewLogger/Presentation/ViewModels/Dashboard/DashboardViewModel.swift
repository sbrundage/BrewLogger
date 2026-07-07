//
//  DashboardViewModel.swift
//  BrewLogger
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

extension DashboardView {
    @MainActor @Observable
    final class ViewModel {
        private let fetchBrews: FetchAllBrewsUseCase
        private let fetchCoffees: FetchAllCoffeesUseCase

        private var brews: [Brew] = []
        private var coffees: [Coffee] = []

        var recentBrews: [Brew] { brews.sorted { $0.date > $1.date } }
        var highestRatedBrews: [Brew] { brews.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) } }
        var mostBrewedCoffees: [Coffee] {
            let counts = Dictionary(grouping: brews, by: \.coffee.id).mapValues(\.count)
            return coffees.sorted { (counts[$0.id] ?? 0) > (counts[$1.id] ?? 0) }
        }

        init(
            brewRepository: BrewRepository = RepositoryFactory.dev.brew,
            coffeeRepository: CoffeeRepository = RepositoryFactory.dev.coffee
        ) {
            fetchBrews = FetchAllBrewsUseCase(repository: brewRepository)
            fetchCoffees = FetchAllCoffeesUseCase(repository: coffeeRepository)
        }

        func fetchAll() {
            do {
                brews = try fetchBrews.execute(coffeeId: nil)
                coffees = try fetchCoffees.execute()
            } catch {
                print("DashboardViewModel fetch failed: \(error)")
            }
        }
    }
}
