//
//  BrewListView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 2/19/26.
//

import SwiftUI
import BrewLoggerDomain

struct BrewListView: View {
    @Environment(BleScaleConnectionManager.self) var connectionManager

    @State private var viewModel = BrewListViewModel()
    
    // Popovers
    @State private var showBlePopover: Bool = false
    @State private var showSortPopover: Bool = false
    
    var body: some View {
        VStack {
            if viewModel.filteredBrews.isEmpty {
                noBrewsView
            } else {
                listView
            }
        } //: VStack
        .onAppear { viewModel.fetchAllBrews() }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("Brews")
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showBlePopover = true
                } label: {
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .foregroundStyle(connectionManager.isConnected ? .green : .secondary)
                }
                .popover(isPresented: $showBlePopover) {
                    BleConnectionView(isConnected: connectionManager.isConnected)
                        .padding()
                        .presentationCompactAdaptation(.popover)
                }
            }
            
            ToolbarItem(placement: .automatic) {
                Button {
                    showSortPopover = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
                .popover(isPresented: $showSortPopover) {
                    ItemPickerView(
                        items: BrewSortOption.allCases,
                        selectedItem: viewModel.selectedSortOption,
                        onItemTap: { option in
                            viewModel.updateSelectedSortOption(option)
                            showSortPopover = false
                        }
                    )
                    .padding()
                    .presentationCompactAdaptation(.popover)
                }
            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddBrewSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddBrewSheet, onDismiss: {
            viewModel.fetchAllBrews()
        }) {
            NavigationStack {
                SaveBrewView()
                    .toolbar {
                        Button {
                            viewModel.showAddBrewSheet = false
                        } label: { Image(systemName: "xmark") }
                    }
            }
            .environment(connectionManager)
        }
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.filteredBrews) { brew in
                NavigationLink {
                    BrewDetailsView(brew: brew)
                } label: {
                    BrewView(brew: brew)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.delete(brew)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
                .navigationLinkIndicatorVisibility(.hidden)
                .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        // TODO: delete brew
//                        viewModel.delete(brew)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var noBrewsView: some View {
        VStack {
            Spacer()
            // TODO: Custom image with animation
            Image(systemName: "cup.and.heat.waves")
                .resizable()
                .frame(width: 60, height: 60)
                .scaledToFit()
                .padding()
            Text(viewModel.noResultsText)
                .font(.headline)
            Spacer()
        }
    }
}

#if DEBUG
import BrewLoggerApplication
#endif

#Preview {
    NavigationStack {
        BrewListView()
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}

