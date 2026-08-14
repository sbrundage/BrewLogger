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

    @State private var viewModel: BrewListViewModel
    
    @State private var brewPendingDelete: Brew?
    @State private var brewToEdit: Brew?

    // Popovers
    @State private var showBlePopover: Bool = false
    @State private var showSortPopover: Bool = false

    init(sortOption: BrewSortOption = .newest) {
        _viewModel = State(initialValue: BrewListViewModel(sortOption: sortOption))
    }

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
        .sheet(isPresented: $viewModel.showAddBrewSheet) {
            NavigationStack {
                SaveBrewView() { viewModel.fetchAllBrews() }
            }
            .environment(connectionManager)
        }
        .sheet(item: $brewToEdit, content: { brew in
            NavigationStack {
                SaveBrewView(brewToEdit: brew) { viewModel.fetchAllBrews() }
            }
        })
        .alert(
            "Delete \(brewPendingDelete?.coffee.name ?? "this brew")?",
            isPresented: Binding(
                get: { brewPendingDelete != nil },
                set: { if !$0 { brewPendingDelete = nil } }
            ),
            presenting: brewPendingDelete
        ) { brew in
            Button("Delete", role: .destructive) { viewModel.delete(brew) }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private var listView: some View {
        List {
            if viewModel.selectedSortOption == .newest {
                ForEach(viewModel.sections) { section in
                    Section {
                        ForEach(section.brews) { brew in
                            row(for: brew)
                        }
                    } header: {
                        sectionHeader(for: section)
                    }
                }
            } else {
                ForEach(viewModel.filteredBrews) { brew in
                    row(for: brew)
                }
            }
        }
        .listStyle(.plain)
        .listSectionSpacing(2)
    }

    private func row(for brew: Brew) -> some View {
        NavigationLink {
            BrewDetailsFormView(brew: brew)
        } label: {
            NewBrewView(brew: brew)
                .listCardBackground()
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        brewPendingDelete = brew
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .contextMenu {
                    Button {
                      brewToEdit = brew
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                }
                .tint(.primary)
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    private func sectionHeader(for section: BrewDateGroup) -> some View {
        HStack {
            Text(viewModel.sectionTitle(for: section.periodStart))
                .font(.subheadline)
                .fontWeight(.semibold)

            Spacer()

            Text("\(section.brews.count) brew\(section.brews.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundStyle(.secondary)

            if let average = section.brews.averageRating {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(average.tens)
                    Image(systemName: "star.fill")
                        .imageScale(.small)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        } //: HStack
        .textCase(nil)
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

