//
//  WeeklyHighlightViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/26/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

extension WeeklyHighlightView {
    @MainActor @Observable
    final class ViewModel {
        private let fetchBrews: FetchAllBrewsUseCase

        private var brews: [Brew] = []

        var topCoffee: Coffee? {
            let grouped = Dictionary(grouping: weekBrews, by: { $0.coffee.id })
            guard let topId = grouped.max(by: { $0.value.count < $1.value.count })?.key else { return nil }
            return weekBrews.first { $0.coffee.id == topId }?.coffee
        }

        var topCoffeeSubtitle: String? {
            guard let topCoffee else { return nil }
            let count = weekBrews.filter { $0.coffee.id == topCoffee.id }.count
            return "\(count) brew\(count == 1 ? "" : "s")"
        }

        var bestBrew: Brew? {
            weekBrews.filter { $0.rating != nil }.max { ($0.rating ?? 0) < ($1.rating ?? 0) }
        }

        var bestBrewSubtitle: String? {
            bestBrew?.rating.map { "\($0.tens) ★" }
        }

        var isEmpty: Bool { topCoffee == nil && bestBrew == nil }

        init(repository: BrewRepository = RepositoryFactory.dev.brew) {
            fetchBrews = FetchAllBrewsUseCase(repository: repository)
        }

        func load() {
            brews = (try? fetchBrews.execute(coffeeId: nil)) ?? []
        }

        private var weekBrews: [Brew] {
            let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return brews.filter { $0.date >= cutoff }
        }
    }
}
