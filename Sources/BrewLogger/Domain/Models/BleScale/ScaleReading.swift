//
//  ScaleReading.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/5/26.
//

import Foundation

public struct ScaleReading: Sendable {
    public let weight: Double      // grams
    public let temperature: Double // °F
    public let humidity: Double    // %

    public init(weight: Double, temperature: Double, humidity: Double) {
        self.weight = weight
        self.temperature = temperature
        self.humidity = humidity
    }
}
