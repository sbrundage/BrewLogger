//
//  CoffeeListView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import SwiftUI
import BrewLoggerDomain

struct CoffeeListView: View {
    @State private var viewModel = CoffeeListViewModel()

    @State private var showSortPopover: Bool = false
    
    @State private var coffeePendingDelete: Coffee?
    @State private var coffeeToEdit: Coffee?

    var body: some View {
        VStack {
            if viewModel.displayedCoffees.isEmpty {
                noDataView
            } else {
                listView
            }
        }
        .onAppear { viewModel.fetchAllCoffees() }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("Coffees")
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    showSortPopover = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
                .popover(isPresented: $showSortPopover) {
                    ItemPickerView(
                        items: CoffeeSortOption.allCases,
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
                    viewModel.showAddCoffeeSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $viewModel.showAddCoffeeSheet) {
            NavigationStack {
                SaveCoffeeView() { _ in viewModel.fetchAllCoffees() }
            }
        }
        .sheet(item: $coffeeToEdit, content: { coffee in
            NavigationStack {
                SaveCoffeeView(coffeeToEdit: coffee) { updatedCoffee in
                    viewModel.updateCoffee(updatedCoffee)
                }
            }
        })
        .navigationDestination(for: Coffee.self) { coffee in
            CoffeeDetailsView(coffee: coffee)
        }
        .alert(
            "Delete \(coffeePendingDelete?.name ?? "Coffee")?",
            isPresented: Binding(
                get: { coffeePendingDelete != nil },
                set: { if !$0 { coffeePendingDelete = nil } }
            ),
            presenting: coffeePendingDelete
        ) { coffee in
            Button("Delete", role: .destructive) { viewModel.delete(coffee) }
            Button("Cancel", role: .cancel) { }
        } message: { coffee in
            Text(viewModel.deleteMessage(for: coffee))
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.displayedCoffees) { coffee in
                NavigationLink(value: coffee.hasDetails ? coffee : nil) {
                    CoffeeView(coffee: coffee, stats: viewModel.stats(for: coffee) ?? .empty)
                        .listCardBackground()
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                coffeePendingDelete = coffee
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                viewModel.toggleFinished(coffee)
                            } label: {
                                Label(
                                    coffee.isFinished ? "Reopen" : "Finished",
                                    systemImage: coffee.isFinished ? "arrow.uturn.backward" : "checkmark"
                                )
                            }
                            .tint(BrandColors.accent)
                        }
                        .contextMenu {
                            Button {
                                coffeeToEdit = coffee
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button {
                                viewModel.toggleFinished(coffee)
                            } label: {
                                Label(
                                    coffee.isFinished ? "Reopen" : "Finished",
                                    systemImage: coffee.isFinished ? "arrow.uturn.backward" : "checkmark"
                                )
                            }

                            Button {
                                coffeePendingDelete = coffee
                            } label : {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .tint(.primary)
                }
                .navigationLinkIndicatorVisibility(.hidden)
                .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }

    private var noDataView: some View {
        VStack {
            Spacer()
            Image(systemName: "cup.and.saucer")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .padding()
            Text(viewModel.noResultsText)
                .font(.headline)
            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        CoffeeListView()
    }
}
