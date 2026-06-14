//
//  AllBrewsViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/13/26.
//

import Foundation
import BrewLoggerDomain

extension AllBrewsView {
    @MainActor
    @Observable
    final class ViewModel {
        private let brews: [Brew]
        
        private(set) var brewMethodSelected: BrewMethod?
        
        private var filteredBrews: [Brew] { brews.filter { $0.method == brewMethodSelected } }
        
        var displayBrews: [Brew] {
            brewMethodSelected != nil ? filteredBrews : brews
        }
        
        var brewMethods: [BrewMethod] { Array(Set(brews.map(\.method))).sorted { $0.title < $1.title } }
        
        var shouldShowMethodFilters: Bool { brewMethods.count > 1 }
        
        init(brews: [Brew]) {
            self.brews = brews
        }
        
        func isMethodSelected(_ method: BrewMethod) -> Bool {
            brewMethodSelected == method
        }
        
        func updateSelectedMethod(_ method: BrewMethod) {
            // Deselect if filter tapped again
            brewMethodSelected = brewMethodSelected == method ? nil : method
        }
    }
}
