//
//  CoffeeSortOption.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/19/26.
//

import Foundation

public enum CoffeeSortOption: CaseIterable, Identifiable, Sendable {
    case recentlyBrewed
    case mostBrewed
    case highestRated
    case freshestRoast

    public var id: Self { self }
}
