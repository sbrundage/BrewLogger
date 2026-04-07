//
//  Brew.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 1/3/26.
//

import Foundation

public struct Brew: Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let coffeeId: String
    public let dose: Double
    public let yield: Double
    public let brewTime: TimeInterval
    public let method: BrewMethod
    public let rating: Int?
    public let notes: String?

    public init(
        id: String = UUID().uuidString,
        date: Date,
        coffeeId: String,
        dose: Double,
        yield: Double,
        brewTime: TimeInterval,
        method: BrewMethod,
        rating: Int?,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.coffeeId = coffeeId
        self.dose = dose
        self.yield = yield
        self.brewTime = brewTime
        self.method = method
        self.rating = rating
        self.notes = notes
    }
}

public enum BrewMethod: Int, Sendable {
    case pourOver = 1
    case espresso = 2
    case na = 3
}
