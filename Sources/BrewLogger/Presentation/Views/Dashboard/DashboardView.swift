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
    // Shared across every destination pushed onto the stack. SaveBrewView (and other
    // views) require @Environment(BleScaleConnectionManager.self); pushed destinations
    // resolve their environment from the stack, not the view that pushed them, so it
    // must live here rather than on individual destinations.
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
                                viewModel.showAddBrewSheet = true
                            } label: {
                                Label("New Brew", systemImage: "cup.and.heat.waves")
                            }

                            Button {
                                viewModel.showAddCoffeeSheet = true
                            } label: {
                                Label("New Coffee", systemImage: "bag")
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
        .defersSystemGestures(on: .bottom)
    }
    
}

#if DEBUG
import BrewLoggerApplication
#endif

#Preview {
    DashboardView()
}
