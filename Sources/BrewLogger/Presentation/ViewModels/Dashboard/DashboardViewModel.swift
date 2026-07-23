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
        private var statsByCoffeeId: [String: CoffeeBrewStats] = [:]

        var recentBrews: [Brew] { brews.sorted { $0.date > $1.date } }
        var highestRatedBrews: [Brew] { brews.sorted { ($0.rating ?? 0) > ($1.rating ?? 0) } }
        var mostBrewedCoffees: [Coffee] {
            coffees.sorted { (stats(for: $0)?.brewCount ?? 0) > (stats(for: $1)?.brewCount ?? 0) }
        }

        func stats(for coffee: Coffee) -> CoffeeBrewStats? {
            statsByCoffeeId[coffee.id]
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
                statsByCoffeeId = brews.statsByCoffeeId()
            } catch {
                print("DashboardViewModel fetch failed: \(error)")
            }
        }
    }
}
