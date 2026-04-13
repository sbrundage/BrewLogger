//
//  Brew.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 1/3/26.
//

import Foundation
import SwiftUI

public struct Brew: Identifiable, Sendable {
    public let id: String
    public let date: Date
    public let coffee: Coffee
    public let dose: Double
    public let yield: Double
    public let brewTime: TimeInterval
    public let method: BrewMethod
    public let rating: Double?
    public let notes: String?

    public init(
        id: String = UUID().uuidString,
        date: Date,
        coffee: Coffee,
        dose: Double,
        yield: Double,
        brewTime: TimeInterval,
        method: BrewMethod,
        rating: Double?,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.coffee = coffee
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
    
    public var image: Image? {
        switch self {
        case .pourOver:
                .init(systemName: "mug")
        case .espresso:
                .init(systemName: "cup.and.saucer")
        case .na: nil
        }
    }
    
    public var title: String {
        switch self {
        case .pourOver:
            "Pour Over"
        case .espresso:
            "Espresso"
        case .na: "N/A"
        }
    }
}
