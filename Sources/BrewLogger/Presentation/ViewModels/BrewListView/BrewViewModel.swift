//
//  BrewViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/9/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
public class BrewViewModel {    
    private(set) var brews: [Brew] = []
    
    var searchText: String = ""
    var showAddBrewSheet: Bool = false
    
    public init(
        repository: BrewRepository = RepositoryFactory.makeBrew(for: .stub)
    ) {
        
    }
}

