//
//  CoffeeView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import BrewLoggerDomain

struct CoffeeView: View {
    private let viewModel: ViewModel

    init(coffee: Coffee, stats: CoffeeBrewStats? = nil, showsFreshness: Bool = true) {
        self.viewModel = ViewModel(coffee: coffee, stats: stats, showsFreshness: showsFreshness)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(viewModel.name)
                        .font(.headline)

                    Spacer()

                    if let roaster = viewModel.roaster {
                        Text(roaster)
                            .font(.subheadline)
                    }
                } //: HStack

                if let origin = viewModel.origin {
                    Text(origin)
                        .font(.subheadline)
                }
            } //: VStack

            if viewModel.showsStatsLine {
                HStack {
                    if let statsText = viewModel.statsText {
                        Text(statsText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let freshness = viewModel.freshness {
                        freshnessChip(freshness)
                    }
                } //: HStack
            }
        } //: VStack
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func freshnessChip(_ freshness: RoastFreshness) -> some View {
        Text("\(freshness.daysOffRoast)d off roast")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(freshness.color)
            .padding(.vertical, 3)
            .padding(.horizontal, 8)
            .background(
                Capsule().fill(freshness.color.opacity(0.15))
            )
    }
}

/// Freshness bands for days off roast. Thresholds live here so they're easy to tune.
struct RoastFreshness {
    static let freshUpperBound = 21
    static let goodUpperBound = 45

    let daysOffRoast: Int

    var color: Color {
        switch daysOffRoast {
        case ...Self.freshUpperBound: BrandColors.accent
        case ...Self.goodUpperBound: .secondary
        default: .orange
        }
    }
}

#Preview("Live Coffee") {
    CoffeeView(
        coffee: .preview,
        stats: CoffeeBrewStats(brewCount: 12, bestRating: 4.5, lastBrewed: Date())
    )
}

#Preview("Finished Coffee") {
    let coffee = Coffee.preview
    let finishedCoffee = Coffee(id: coffee.id, name: coffee.name, originInfo: coffee.originInfo, roastInfo: coffee.roastInfo, process: coffee.process, variety: coffee.variety, finishedAt: coffee.roastInfo?.date)
    CoffeeView(
        coffee: finishedCoffee,
        stats: CoffeeBrewStats(brewCount: 12, bestRating: 4.5, lastBrewed: Date())
    )
}

#Preview("Empty Coffee") {
    let emptyCoffee = Coffee(id: UUID().uuidString, name: "Test Coffee", originInfo: nil, roastInfo: nil, process: nil, variety: nil, finishedAt: nil)
    CoffeeView(coffee: emptyCoffee)
}
