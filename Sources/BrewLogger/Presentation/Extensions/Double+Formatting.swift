//
//  Double+Formatting.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/11/26.
//

import Foundation

extension Double {
    var tens: String { "\(formatted(.number.precision(.fractionLength(1))))" }
}
