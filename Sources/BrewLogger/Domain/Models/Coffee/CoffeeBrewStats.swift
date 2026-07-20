//
//  CoffeeBrewStats.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/20/26.
//

import Foundation

/// Per-coffee brew aggregates.
public struct CoffeeBrewStats: Equatable, Sendable {
    public let brewCount: Int
    public let bestRating: Double?
    public let lastBrewed: Date?

    public init(brewCount: Int, bestRating: Double?, lastBrewed: Date?) {
        self.brewCount = brewCount
        self.bestRating = bestRating
        self.lastBrewed = lastBrewed
    }

    /// Zero brews, distinct from nil ("not computed").
    public static let empty = CoffeeBrewStats(brewCount: 0, bestRating: nil, lastBrewed: nil)
}
