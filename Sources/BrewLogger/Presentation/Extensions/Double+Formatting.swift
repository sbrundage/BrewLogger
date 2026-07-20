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

extension TimeInterval {
    // Whole seconds under a minute ("28s"), m:ss above ("2:45").
    var brewTimeFormatted: String {
        let total = Int(rounded())
        guard total >= 60 else { return "\(total)s" }
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
