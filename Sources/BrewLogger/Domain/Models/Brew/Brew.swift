//
//  Brew.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 1/3/26.
//

import Foundation

public struct Brew: Identifiable, Equatable, Sendable {
    public let id: String
    public let date: Date
    public let coffee: Coffee
    public let grindSize: Double
    public let dose: Double
    public let yield: Double
    public let brewTime: TimeInterval
    public let method: BrewMethod
    public let brewTemp: Int?
    public let tastingEntries: [TastingEntry]

    public var rating: Double? { tastingEntries.compactMap(\.rating).max() }

    public init(
        id: String,
        date: Date,
        coffee: Coffee,
        grindSize: Double,
        dose: Double,
        yield: Double,
        brewTime: TimeInterval,
        method: BrewMethod,
        brewTemp: Int?,
        tastingEntries: [TastingEntry] = []
    ) {
        self.id = id
        self.date = date
        self.coffee = coffee
        self.grindSize = grindSize
        self.dose = dose
        self.yield = yield
        self.brewTime = brewTime
        self.method = method
        self.brewTemp = brewTemp
        self.tastingEntries = tastingEntries
    }
}
