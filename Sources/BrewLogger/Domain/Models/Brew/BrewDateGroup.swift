//
//  BrewDateGroup.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/20/26.
//

import Foundation

/// Brews bucketed into one calendar day.
public struct BrewDateGroup: Identifiable, Equatable, Sendable {
    public let periodStart: Date
    public let brews: [Brew]

    public var id: Date { periodStart }

    public init(periodStart: Date, brews: [Brew]) {
        self.periodStart = periodStart
        self.brews = brews
    }
}
