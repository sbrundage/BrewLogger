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
                        // TODO: navigate to see all brews view
                    })
                    .padding(.bottom)
                }
                
                #if canImport(FoundationModels)
                if let originInfo = viewModel.coffee.originInfo, #available(iOS 26.0, *) {
                    OriginView(origin: originInfo)
                }
                #endif
                
                Spacer()
            } //: VStack
            .padding(.horizontal)
        }
        .navigationTitle(viewModel.coffee.name)
        .task {
            await viewModel.fetchAllBrews()
        }
    }
    
    // MARK: Roast Info
    
    private func roastInfoView(roast: RoastInfo) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Roast Info")
                .font(.headline)
            
            HStack {
                if let roastDate = roast.date {
                    VStack {
                        Text("Roast Date")
                            .fontWeight(.light)
                        Text("\(roastDate.shortFormatted)")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                if let roaster = roast.roaster {
                    VStack {
                        Text("Roaster")
                            .fontWeight(.light)
                        Text("\(roaster)")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                }
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                if let roastLevel = roast.roastLevel {
                    VStack {
                        Text("Roast Level")
                            .fontWeight(.light)
                        Text("\(roastLevel.title)")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                }
            } //: HStack
        } //: VStack
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    CoffeeDetailsView(coffee: Coffee.previewList[0])
}
