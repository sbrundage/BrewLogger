//
//  Matchable.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/9/26.
//

import Foundation

public protocol Matchable {
    func isMatch(for searchQuery: String) -> Bool
}
