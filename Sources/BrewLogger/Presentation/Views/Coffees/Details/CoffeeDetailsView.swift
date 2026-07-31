//
//  CoffeeDetailsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/3/26.
//

import SwiftUI
import BrewLoggerDomain

struct CoffeeDetailsView: View {
    @State private var viewModel: CoffeeDetailsViewModel
    @State private var showAllBrews = false
    @State private var showEditSheet = false
    
    init(coffee: Coffee) {
        self.viewModel = CoffeeDetailsViewModel(coffee: coffee)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if let roastInfo = viewModel.coffee.roastInfo {
                    roastInfoView(roast: roastInfo)
                        .padding(.bottom)
                }
                
                if !viewModel.brews.isEmpty {
                    if !viewModel.highestRatedBrews.isEmpty {
                        HighestRatedBrewsView(brews: viewModel.highestRatedBrews)
                            .padding(.bottom)
                    }
                    
                    SeeSomeView(
                        items: viewModel.brews,
                        title: "Recent Brews", onSeeAllTapped: {
                            showAllBrews = true
                        }) { brew in
                            BrewRow(brew: brew)
                        }
                        .padding(.bottom)
                }
                
                #if canImport(FoundationModels)
                if let originInfo = viewModel.coffee.originInfo, #available(iOS 26.0, *) {
                    OriginView(origin: originInfo)
                }
                #endif
                
            } //: VStack
            .padding(.horizontal)
        }
        .navigationTitle(viewModel.coffee.name)
        .scrollIndicators(.hidden)
        .navigationDestination(isPresented: $showAllBrews, destination: {
            AllBrewsView(title: viewModel.coffee.name, brews: viewModel.brews)
        })
        .navigationDestination(isPresented: $showEditSheet, destination: {
            SaveCoffeeView(coffeeToEdit: viewModel.coffee) { _ in
                viewModel.refetchCoffee()
            }
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditSheet = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .onAppear { viewModel.fetchAllBrews() }
    }
    
    // MARK: Roast Info

    private func roastInfoView(roast: RoastInfo) -> some View {
        let stats: [StatRow.Stat] = [
            roast.date.map { .init(label: "Roast Date", value: $0.shortFormatted) },
            roast.roaster.map { .init(label: "Roaster", value: $0) },
            roast.roastLevel.map { .init(label: "Roast Level", value: $0.title) }
        ].compactMap { $0 }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Roast Info")
                .font(.headline)

            StatRow(stats: stats)
        }
    }
}

#Preview {
    NavigationStack {
        CoffeeDetailsView(coffee: Coffee.previewList[0])
    }
}
