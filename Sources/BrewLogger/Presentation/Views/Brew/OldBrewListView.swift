//
//  BrewListView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 2/19/26.
//

import SwiftUI

//struct BrewListView: View {
//    @Environment(BleScaleViewModel.self) var scaleViewModel
//
//    @State private var viewModel = BrewViewModel()
//    
//    var body: some View {
//        VStack {
//            Text(scaleViewModel.connectionState.description) // need to add description to BLEConnectionState
//            
//            if viewModel.brews.isEmpty {
//                Text("Add a brew to get started")
//                    .font(.headline)
//                
//                // TODO: Custom image with animation
//                Image(systemName: "cup.and.heat.waves")
//                    .resizable()
//                    .frame(width: 60, height: 60)
//                    .scaledToFit()
//                    .padding()
//            } else {
//                listView
//            }
//        } //: VStack
//        .onAppear {
//            viewModel.fetchAllBrews()
//        }
//        .searchable(text: $viewModel.searchText)
//        .navigationTitle("Brew History")
//        .toolbar {
//            ToolbarItem(placement: .primaryAction) {
//                Button {
//                    viewModel.showAddBrewSheet = true
//                } label: {
//                    Image(systemName: "plus")
//                }
//            }
//            
//            
////            ToolbarItem(placement: .automatic) {
////                Button {
////                    // TODO: Add filtering / sorting
////                } label: {
////                    Image(systemName: "line.3.horizontal.decrease")
////                }
////            }
//        }
//        .sheet(isPresented: $viewModel.showAddBrewSheet, onDismiss: {
//            viewModel.fetchAllBrews()
//        }) {
//            NavigationStack {
//                AddBrewView()
//                    .toolbar {
//                        Button {
//                            viewModel.showAddBrewSheet = false
//                        } label: { Image(systemName: "xmark") }
//                    }
//            }
//        }
//    }
//    
//    private var listView: some View {
//        List {
//            ForEach(viewModel.brews) { brew in
//                BrewView(brew: brew)
//                    .listRowBackground(Color.clear)
//                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
//                    .listRowSeparator(.hidden)
//                    .swipeActions(edge: .trailing) {
//                        Button(role: .destructive) {
//                            viewModel.delete(brew)
//                        } label: {
//                            Label("Delete", systemImage: "trash")
//                        }
//                    }
//            }
//        }
//        .listStyle(.plain)
//    }
//}
//
//#Preview {
//    NavigationStack {
//        BrewListView()
//    }
//}
