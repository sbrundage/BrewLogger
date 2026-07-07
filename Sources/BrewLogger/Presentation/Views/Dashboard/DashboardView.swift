//
//  DashboardView.swift
//  BrewLogger
//

import SwiftUI
import BrewLoggerDomain

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
                            Button {
                                viewModel.showAddCoffeeSheet = true
                            } label: {
                                Label("New Coffee", systemImage: "bag")
                            }
                            
                            Button {
                                viewModel.showAddBrewSheet = true
                            } label: {
                                Label("New Brew", systemImage: "cup.and.heat.waves")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .tint(BrandColors.accent)
                    }
                }
                .sheet(isPresented: $viewModel.showAddBrewSheet, onDismiss: { viewModel.fetchAll() }) {
                    NavigationStack {
                        SaveBrewView()
                            .toolbar {
                                Button { viewModel.showAddBrewSheet = false } label: { Image(systemName: "xmark") }
                            }
                    }
                    .environment(connectionManager) // SaveBrewView requires @Environment(BleScaleConnectionManager.self); sheets present in a new context
                }
                .sheet(isPresented: $viewModel.showAddCoffeeSheet, onDismiss: { viewModel.fetchAll() }) {
                    NavigationStack {
                        SaveCoffeeView()
                            .toolbar {
                                Button { viewModel.showAddCoffeeSheet = false } label: { Image(systemName: "xmark") }
                            }
                    }
                }
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
