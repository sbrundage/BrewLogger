//
//  BrewSortOption.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/16/26.
//

import Foundation

public enum BrewSortOption: CaseIterable, Identifiable {
    case highestRated
    case newest
    
    public var id: Self { self }
}
