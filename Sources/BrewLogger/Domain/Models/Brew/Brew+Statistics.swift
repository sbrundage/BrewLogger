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
