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
        .sheet(isPresented: $viewModel.showAddCoffeeSheet, onDismiss: {
            viewModel.fetchAllCoffees()
        }) {
            NavigationStack {
                SaveCoffeeView()
                    .toolbar {
                        Button {
                            viewModel.showAddCoffeeSheet = false
                        } label: { Image(systemName: "xmark") }
                    }
            }
        }
        .navigationDestination(for: Coffee.self) { coffee in
            CoffeeDetailsView(coffee: coffee)
        }
    }

    private var listView: some View {
        List {
            ForEach(viewModel.displayedCoffees) { coffee in
                NavigationLink(value: coffee.hasDetails ? coffee : nil) {
                    CoffeeView(coffee: coffee, stats: viewModel.stats(for: coffee) ?? .empty)
                        .listCardBackground()
                }
                .navigationLinkIndicatorVisibility(.hidden)
                .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        viewModel.delete(coffee)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
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
