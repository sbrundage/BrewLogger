//
//  SwiftUIView.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/23/26.
//

import SwiftUI
import BrewLoggerApplication
import BrewLoggerDomain

public struct DashboardView: View {
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            
            VStack(spacing: 18) {
                SeeSomeView(
                    items: Brew.previewList,
                    title: "Recent Brews 1",
                    onSeeAllTapped: {
                        
                    }) { brew in
                        NewBrewView(brew: brew)
                    }
                
                SeeSomeView(
                    items: Brew.previewList,
                    title: "Recent Brews 2",
                    onSeeAllTapped: {
                        
                    }) { brew in
                        NewBrewView2(brew: brew)
                    }
                
                SeeSomeView(
                    items: Brew.previewList,
                    title: "Recent Brews 3",
                    onSeeAllTapped: {
                        
                    }) { brew in
                        NewBrewView3(brew: brew)
                    }
                
                SeeSomeView(
                    items: Brew.previewList,
                    title: "Top Brews",
                    onSeeAllTapped: {
                        
                    }) { brew in
                        BrewRow(brew: brew)
                    }
                
                SeeSomeView(
                    items: Coffee.previewList,
                    title: "Most Brewed",
                    onSeeAllTapped: {
                        
                    }) { coffee in
                        CoffeeView(coffee: coffee)
                    }
            } //: VStack
            .padding(.horizontal)
        }
        .navigationTitle("Pocket Logger")
    }
}

private extension DashboardView {
    @MainActor @Observable
    final class ViewModel {
        private let fetchBrews: FetchAllBrewsUseCase
        
        private(set) var brews: [Brew] = []
        
        init(
            repository: BrewRepository = RepositoryFactory.dev.brew
        ) {
            self.fetchBrews = FetchAllBrewsUseCase(repository: repository)
        }
        
        func fetchAllBrews() {
            do {
                self.brews = try fetchBrews.execute(coffeeId: nil)
            } catch {
                // TODO: Handle error
                print("Failed to fetch brews: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
