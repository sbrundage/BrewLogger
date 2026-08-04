//
//  BrewsThisWeekIntent.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/1/26.
//

import AppIntents
import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

public struct BrewsThisWeekIntent: AppIntent {
    public static let title: LocalizedStringResource = "Brews This Week"
    public static let description = IntentDescription("Shows how many brews you've logged in the past week.")

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog & ShowsSnippetView {
        RepositoryFactory.bootstrap()
        let week = try RepositoryFactory.dev.brew.fetchAll(for: nil).brewed(inLast: 7)
        let count = week.count

        let dialog: IntentDialog = switch count {
        case 0: "You haven't logged any brews this week."
        case 1: "You've logged 1 brew this week."
        default: "You've logged \(count) brews this week."
        }
        return .result(dialog: dialog, view: WeeklyBrewsSnippetView(snippet: makeSnippet(from: week)))
    }

    private func makeSnippet(from week: [Brew]) -> WeeklyBrewsSnippet {
        let coffees = week.summariesPerCoffee().map { coffee, stats in
            WeeklyBrewsSnippet.CoffeeRow(
                id: coffee.id,
                name: coffee.name,
                countText: stats.brewCount == 1 ? "1×" : "\(stats.brewCount)×",
                bestRatingText: stats.bestRating.map { String(format: "%.1f", $0) }
            )
        }

        return WeeklyBrewsSnippet(
            headline: week.count == 1 ? "1 brew this week" : "\(week.count) brews this week",
            coffees: coffees
        )
    }
}
