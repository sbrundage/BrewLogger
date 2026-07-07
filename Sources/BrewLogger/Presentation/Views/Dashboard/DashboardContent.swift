//
//  DashboardContent.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/30/26.
//

import SwiftUI

/// Destinations for the dashboard "See All" buttons.
private enum SeeAllRoute: Hashable {
    case recentBrews  // → BrewListView, newest first (default)
    case mostBrewed   // → CoffeeListView
}


/// Swaps between the dashboard sections and the search screen based on whether search is
/// active. `isSearching` is only visible to descendants of the `.searchable` modifier, so
/// this lives in a child view of `DashboardView`.
struct DashboardContent: View {
    @Environment(\.isSearching) private var isSearching
    
    @Binding private var path: NavigationPath
    
    private let viewModel: DashboardView.ViewModel
    
    public init(viewModel: DashboardView.ViewModel, path: Binding<NavigationPath>) {
        self.viewModel = viewModel
        self._path = path
    }
    
    var body: some View {
        Group {
            if isSearching {
                SearchResultsView()
            } else {
                home
            }
        }
        .navigationDestination(for: SeeAllRoute.self) { route in
            switch route {
            case .recentBrews:
                BrewListView(sortOption: .newest)
            case .mostBrewed:
                CoffeeListView()
            }
        }
    }
    
    private var home: some View {
        ScrollView {
            VStack(spacing: 18) {
                SeeSomeView(
                    items: viewModel.recentBrews,
                    title: "Recent Brews",
                    onSeeAllTapped: { path.append(SeeAllRoute.recentBrews) }) { brew in
                        NewBrewView(brew: brew)
                    }
                
                SeeSomeView(
                    items: viewModel.mostBrewedCoffees,
                    title: "Most Brewed",
                    onSeeAllTapped: { path.append(SeeAllRoute.mostBrewed) }) { coffee in
                        CoffeeView(coffee: coffee)
                    }
            }
            .padding(.horizontal)
        }
    }
}
