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
                    
                    RecentBrewsView(brews: viewModel.brews, onSeeAllTapped: {
                        showAllBrews = true
                    })
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
        .navigationDestination(isPresented: $showAllBrews, destination: {
            AllBrewsView(title: viewModel.coffee.name, brews: viewModel.brews)
        })
        .task {
            await viewModel.fetchAllBrews()
        }
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
        } //: VStack
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        CoffeeDetailsView(coffee: Coffee.previewList[0])
    }
}
