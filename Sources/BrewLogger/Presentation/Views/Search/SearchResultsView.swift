//
//  SearchResultsView.swift
//  BrewLogger
//

import SwiftUI

/// Compact, Notes-style list shown while the dashboard search is active: a short list of
/// categories the user can tap to refine their search. Tap behavior is intentionally a
/// no-op for now — the refine/results logic is handled separately.
struct SearchResultsView: View {
    private enum Category: String, CaseIterable, Identifiable {
        case coffees = "Coffees"
        case brews = "Brews"
        case origins = "Origins"
        case notes = "Notes"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .coffees: "cup.and.saucer.fill"
            case .brews: "cup.and.heat.waves"
            case .origins: "globe"
            case .notes: "note.text"
            }
        }
    }

    var body: some View {
        List(Category.allCases) { category in
            Button {
                // TODO: refine search by category
            } label: {
                HStack {
                    Image(systemName: category.icon)
                        .foregroundStyle(BrandColors.accent)
                    Text(category.rawValue)
                } //: HStack
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    SearchResultsView()
}
