//
//  BrewListView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 2/19/26.
//

import SwiftUI
import BrewLoggerApplication

struct BrewListView: View {
    @Environment(BleScaleConnectionManager.self) var connectionManager

    @State private var viewModel = BrewViewModel()
    
    var body: some View {
        VStack {
            BleConnectionView(isConnected: connectionManager.isConnected)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            if viewModel.brews.isEmpty {
                noBrewsView
            } else {
                listView
            }
        } //: VStack
        .onAppear { viewModel.fetchAllBrews() }
        .searchable(text: $viewModel.searchText)
        .navigationTitle("Brew History")
        .frame(maxHeight: .infinity, alignment: .top)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddBrewSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            
//            ToolbarItem(placement: .automatic) {
//                Button {
//                    // TODO: Add filtering / sorting
//                } label: {
//                    Image(systemName: "line.3.horizontal.decrease")
//                }
//            }
        }
        .sheet(isPresented: $viewModel.showAddBrewSheet, onDismiss: {
            viewModel.fetchAllBrews()
        }) {
            NavigationStack {
                AddBrewView()
                    .toolbar {
                        Button {
                            viewModel.showAddBrewSheet = false
                        } label: { Image(systemName: "xmark") }
                    }
            }
        }
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.brews) { brew in
                BrewView(brew: brew)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .listRowSeparator(.hidden)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.delete(brew)
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
            Text("Add a brew to get started")
                .font(.headline)
            Spacer()
        }
    }
}

import BrewLoggerData

#Preview {
    NavigationStack {
        BrewListView()
    }
    .environment(BleScaleConnectionManager(repository: RepositoryFactory.stub.scale))
}
