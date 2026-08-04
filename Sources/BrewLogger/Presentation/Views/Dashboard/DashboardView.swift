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
                .searchable(text: $searchText, prompt: "Search")
                .toolbar {
                    DefaultToolbarItem(kind: .search, placement: .bottomBar)
                    ToolbarSpacer(.flexible, placement: .bottomBar)
                    ToolbarItem(placement: .bottomBar) {
                        Menu {
                            Button { path.append(AddRoute.coffee) } label: {
                                Label("New Bean", systemImage: "bag")
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
}

#if DEBUG
import BrewLoggerApplication
#endif

#Preview {
    DashboardView()
}
