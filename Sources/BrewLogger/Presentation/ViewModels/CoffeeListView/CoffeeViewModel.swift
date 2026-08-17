//
//  CoffeeViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/20/26.
//

import Foundation
import BrewLoggerDomain

extension CoffeeView {
    struct ViewModel {
        let coffee: Coffee
        let stats: CoffeeBrewStats?
        let showsFreshness: Bool

        var name: String { coffee.name }
        var roaster: String? { coffee.roastInfo?.roaster }
        var origin: String? { coffee.originInfo?.location }

        var showsStatsLine: Bool { stats != nil }

        var statsText: String? {
            guard let stats else { return nil }
            guard stats.brewCount > 0 else { return "No brews yet" }
            var parts = ["\(stats.brewCount) brew\(stats.brewCount == 1 ? "" : "s")"]
            if let best = stats.bestRating { parts.append("best \(best.tens) ★") }
            if let lastBrewed = stats.lastBrewed { parts.append("last \(lastBrewed.monthDay)") }
            return parts.joined(separator: " · ")
        }

        var freshness: RoastFreshness? {
            guard
                showsFreshness,
                !coffee.isFinished,
                let roastDate = coffee.roastInfo?.date
            else { return nil }
            let days = Calendar.current.dateComponents([.day], from: roastDate, to: Date()).day ?? 0
            return RoastFreshness(daysOffRoast: days)
        }
    }
}
