//
//  OriginInfo.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import Foundation

public struct OriginInfo: Sendable, Equatable {
    public let location: String
    public let altitude: Int?
    public let latitude: Double?
    public let longitude: Double?
    public let canonicalName: String?

    public var hasCoordinate: Bool { latitude != nil && longitude != nil }

    // Canonical place name when resolved, else the raw entry; the key origins are grouped/deduped by.
    public var groupingKey: String { canonicalName ?? location }

    // The stored coordinate expressed as a GeocodeResult, or nil when unresolved.
    public var geocodeResult: GeocodeResult? {
        guard let latitude, let longitude else { return nil }
        return GeocodeResult(latitude: latitude, longitude: longitude, canonicalName: canonicalName)
    }

    public init(
        location: String,
        altitude: Int?,
        latitude: Double? = nil,
        longitude: Double? = nil,
        canonicalName: String? = nil
    ) {
        self.location = location
        self.altitude = altitude
        self.latitude = latitude
        self.longitude = longitude
        self.canonicalName = canonicalName
    }

    public init(location: String, altitude: Int?, from result: GeocodeResult?) {
        self.init(
            location: location,
            altitude: altitude,
            latitude: result?.latitude,
            longitude: result?.longitude,
            canonicalName: result?.canonicalName
        )
    }

    public func applying(_ result: GeocodeResult) -> OriginInfo {
        OriginInfo(location: location, altitude: altitude, from: result)
    }
}
