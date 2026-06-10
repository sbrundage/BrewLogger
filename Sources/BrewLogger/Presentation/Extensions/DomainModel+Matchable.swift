//
//  DomainModel+Matchable.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/9/26.
//

import Foundation
import BrewLoggerDomain

extension Brew: Matchable {
    public func isMatch(for searchQuery: String) -> Bool {
        let lowercasedQuery = searchQuery.lowercased()
        return coffee.name.lowercased().contains(lowercasedQuery)
    }
}

extension Coffee: Matchable {
    public func isMatch(for searchQuery: String) -> Bool {
        let lowercasedQuery = searchQuery.lowercased()
        return name.lowercased().contains(lowercasedQuery) ||
        roastInfo?.roaster?.lowercased().contains(lowercasedQuery) ?? false ||
        originInfo?.location.lowercased().contains(lowercasedQuery) ?? false
    }
}
