//
//  CoffeeDetailsView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/3/26.
//

import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
final class CoffeeDetailsViewModel {
    private let fetchBrews: FetchAllBrewsUseCase
//    private let originInfoLookup: OriginLookupUseCase
    
    private(set) var brews: [Brew] = []
    
    init(
        repository: BrewRepository = RepositoryFactory.dev.brew
    ) {
        self.fetchBrews = FetchAllBrewsUseCase(repository: repository)
    }
}

struct CoffeeDetailsView: View {
    @State private var viewModel = CoffeeDetailsViewModel()
    
    let coffee: Coffee
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                //            brewInfoView
                //                .padding(.bottom)
                
                highestRatedView
                    .padding(.bottom)
                
                if let roastInfo = coffee.roastInfo {
                    roastInfoView(roast: roastInfo)
                        .padding(.bottom)
                }
                
                if true /*!viewModel.brews.isEmpty*/ {
                    Text("Past Brews Log / Chart View")
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(.secondary)
                        .padding(.bottom)
                }
                
                #if canImport(FoundationModels)
                if let originInfo = coffee.originInfo, #available(iOS 26.0, *) {
                    OriginView(origin: originInfo)
                }
                #endif
                
                Spacer()
            } //: VStack
            .padding(.horizontal)
        }
        .navigationTitle(coffee.name)
    }
    
    // MARK: Brew Info
    
    private var highestRatedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Highest Rated Brew")
                .font(.headline)
            
            HStack {
                    VStack {
                        Text("Grind Size")
                            .fontWeight(.light)
                        Text("0.5")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Time")
                            .fontWeight(.light)
                        Text("30s")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Yield")
                            .fontWeight(.light)
                        Text("34g")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
            } //: HStack
        } //: VStack
    }
    
    private var brewInfoView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Brew History")
                .font(.headline)
            
            HStack {
                    VStack {
                        Text("Brews")
                            .fontWeight(.light)
                        Text("20")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Time")
                            .fontWeight(.light)
                        Text("30s")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
                
                Divider()
                    .frame(width: 0.5, height: 30)
                    .overlay(.secondary)
                
                    VStack {
                        Text("Yield")
                            .fontWeight(.light)
                        Text("34g")
                            .fontWeight(.medium)
                    } //: VStack
                    .frame(maxWidth: .infinity)
            } //: HStack
        } //: VStack
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
    CoffeeDetailsView(coffee: Coffee.preview)
}
