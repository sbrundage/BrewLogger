//
//  Listable.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/14/26.
//

import Foundation
import BrewLoggerDomain

protocol Listable: Identifiable, Equatable {
    var title: String { get }
}

extension Coffee: Listable {
    var title: String { name }
}

extension BrewMethod: Listable {}

extension RoastLevel: Listable {
    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

extension ProcessMethod: Listable {
    public var id: String { rawValue }
    public var title: String { rawValue.capitalized }
}

extension BrewSortOption: Listable {
    public var title: String {
        switch self {
        case .newest: return "Newest"
        case .highestRated: return "Highest Rated"
        }
    }
}
