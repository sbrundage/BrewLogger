//
//  DashboardView.swift
//  BrewLogger
//

import SwiftUI
import BrewLoggerDomain

private enum AddRoute: Hashable {
    case brew
    case coffee
}

public struct DashboardView: View {
    private let coordinator = AppNavigationCoordinator.shared

    @State private var viewModel = ViewModel()
    @State private var searchText = ""
    @State private var path = NavigationPath()
    @State private var connectionManager = BleScaleConnectionManager()

    public init() {}
    
    public var body: some View {
        NavigationStack(path: $path) {
            DashboardContent(viewModel: viewModel, path: $path)
                .navigationTitle("Pocket Logger")
                .onAppear { viewModel.fetchAll() }
                .onChange(of: coordinator.pendingDestination, initial: true) { _, destination in
                    apply(destination)
                }
                .searchable(text: $searchText, prompt: "Search")
                .toolbar {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Menu {
                            Button { path.append(AddRoute.coffee) } label: {
                                Label("New Coffee", systemImage: "bag")
                            }
                            
                            Button { path.append(AddRoute.brew) } label: {
                                Label("New Brew", systemImage: "cup.and.heat.waves")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .tint(BrandColors.accent)
                    }
                }
                .navigationDestination(for: AddRoute.self, destination: { route in
                    switch route {
                    case .brew:
                        SaveBrewView(onSuccessfulSave: { viewModel.fetchAll() })
                    case .coffee:
                        SaveCoffeeView(onSuccessfulSave: { _ in viewModel.fetchAll() })
                    }
                })
        }
        .environment(connectionManager)
    }

    @MainActor
    private func apply(_ destination: AppDestination?) {
        guard let destination else { return }
        coordinator.pendingDestination = nil   // clear first so a re-entrant fire can't push twice
        switch destination {
        case .addBrew:
            path.append(AddRoute.brew)
        }
    }
}

#if DEBUG
import BrewLoggerApplication
#endif

#Preview {
    DashboardView()
}
