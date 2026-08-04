//
//  WeeklyBrewsSnippetView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/3/26.
//

import SwiftUI

public struct WeeklyBrewsSnippet: Sendable, Equatable {
    public struct CoffeeRow: Sendable, Equatable, Identifiable {
        public let id: String
        public let name: String
        public let countText: String
        public let bestRatingText: String?

        public init(id: String, name: String, countText: String, bestRatingText: String?) {
            self.id = id
            self.name = name
            self.countText = countText
            self.bestRatingText = bestRatingText
        }
    }

    public let headline: String
    public let coffees: [CoffeeRow]

    public init(headline: String, coffees: [CoffeeRow]) {
        self.headline = headline
        self.coffees = coffees
    }
}

struct WeeklyBrewsSnippetView: View {
    let snippet: WeeklyBrewsSnippet

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "cup.and.heat.waves.fill")
                    .foregroundStyle(BrandColors.accent)
                Text(snippet.headline)
                    .font(.headline)
                Spacer()
                Text("Past 7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)

            if snippet.coffees.isEmpty {
                Text("No brews logged this week.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(Array(snippet.coffees.enumerated()), id: \.element.id) { index, coffee in
                    if index > 0 { Divider() }
                    row(coffee)
                }
            }
        }
        .padding()
    }

    private func row(_ coffee: WeeklyBrewsSnippet.CoffeeRow) -> some View {
        HStack(spacing: 10) {
            Text(coffee.name)
                .font(.subheadline.weight(.medium))
                .lineLimit(1)

            Spacer(minLength: 8)

            Text(coffee.countText)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(BrandColors.accent.opacity(0.15), in: Capsule())
                .foregroundStyle(BrandColors.accent)

            if let bestRatingText = coffee.bestRatingText {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                    Text(bestRatingText)
                }
                .font(.caption.weight(.medium))
                .foregroundStyle(.orange)
                .lineLimit(1)
                .fixedSize()
            } else {
                Text("—")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize()
            }
        }
        .padding(.vertical, 7)
    }
}
