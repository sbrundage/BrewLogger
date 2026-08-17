//
//  GeocodeResult.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/7/26.
//

import Foundation

public struct GeocodeResult: Sendable, Equatable {
    public let latitude: Double
    public let longitude: Double
    public let canonicalName: String?

    public init(latitude: Double, longitude: Double, canonicalName: String?) {
        self.latitude = latitude
        self.longitude = longitude
        self.canonicalName = canonicalName
    }
}
