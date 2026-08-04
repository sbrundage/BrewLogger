//
//  Brew+Statistics.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/19/26.
//

import Foundation

public extension Array where Element == Brew {
    /// Aggregates the brews into per-coffee stats keyed by coffee id.
    func statsByCoffeeId() -> [String: CoffeeBrewStats] {
        Dictionary(grouping: self, by: \.coffee.id).mapValues { brews in
            CoffeeBrewStats(
                brewCount: brews.count,
                bestRating: brews.bestRating,
                lastBrewed: brews.map(\.date).max()
            )
        }
    }

    /// Brews dated within the last `days` days of `now`.
    func brewed(inLast days: Int, calendar: Calendar = .current, now: Date = Date()) -> [Brew] {
        guard let cutoff = calendar.date(byAdding: .day, value: -days, to: now) else { return self }
        return filter { $0.date >= cutoff }
    }

    /// Per-coffee stats paired with the coffee, most-brewed first (ties broken by name).
    func summariesPerCoffee() -> [(coffee: Coffee, stats: CoffeeBrewStats)] {
        Dictionary(grouping: self, by: \.coffee.id)
            .values
            .map { brews in
                (brews[0].coffee,
                 CoffeeBrewStats(
                    brewCount: brews.count,
                    bestRating: brews.bestRating,
                    lastBrewed: brews.map(\.date).max()
                 ))
            }
            .sorted {
                $0.stats.brewCount != $1.stats.brewCount
                    ? $0.stats.brewCount > $1.stats.brewCount
                    : $0.coffee.name.localizedCaseInsensitiveCompare($1.coffee.name) == .orderedAscending
            }
    }

    /// Average of the non-nil ratings; nil when no brew has a rating.
    var averageRating: Double? {
        let ratings = compactMap(\.rating)
        guard !ratings.isEmpty else { return nil }
        return ratings.reduce(0, +) / Double(ratings.count)
    }

    /// Highest rating; nil when unrated.
    var bestRating: Double? {
        compactMap(\.rating).max()
    }

    /// Groups ordered newest day first; brews within a day newest first.
    func groupedByDay(calendar: Calendar = .current) -> [BrewDateGroup] {
        let buckets = Dictionary(grouping: self) { calendar.startOfDay(for: $0.date) }
        return buckets
            .map { BrewDateGroup(periodStart: $0.key, brews: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.periodStart > $1.periodStart }
    }
}
