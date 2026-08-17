//
//  WeeklyHighlightView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/26/26.
//

import SwiftUI
import BrewLoggerDomain

struct WeeklyHighlightView: View {
    private let horizontalPadding: CGFloat = 14

    @State private var viewModel = ViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Last 7 Days")
                .font(.system(size: 22, weight: .semibold))
                .padding(.bottom, 8)
                .padding(.horizontal, horizontalPadding)

            VStack(spacing: 0) {
                content
            }
            .padding(horizontalPadding)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.gray.opacity(0.2))
            )
        }
        .onAppear { viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEmpty {
            Text("No brews logged this week")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            if let coffee = viewModel.topCoffee {
                NavigationLink {
                    CoffeeDetailsView(coffee: coffee)
                } label: {
                    HighlightRow(
                        icon: "cup.and.saucer.fill",
                        label: "Top Coffee",
                        title: coffee.name,
                        trailing: viewModel.topCoffeeSubtitle
                    )
                }
                .buttonStyle(.plain)
                .navigationLinkIndicatorVisibility(.hidden)
            }

            if viewModel.topCoffee != nil && viewModel.bestBrew != nil {
                Divider().padding(.vertical, 12)
            }

            if let brew = viewModel.bestBrew {
                NavigationLink {
                    BrewDetailsFormView(brew: brew)
                } label: {
                    HighlightRow(
                        icon: "star.fill",
                        label: "Best Brew",
                        title: brew.coffee.name,
                        trailing: viewModel.bestBrewSubtitle
                    )
                }
                .buttonStyle(.plain)
                .navigationLinkIndicatorVisibility(.hidden)
            }
        }
    }
}

private struct HighlightRow: View {
    let icon: String
    let label: String
    let title: String
    let trailing: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(BrandColors.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(title)
            }

            Spacer()

            if let trailing {
                Text(trailing)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    NavigationStack {
        WeeklyHighlightView()
    }
}
