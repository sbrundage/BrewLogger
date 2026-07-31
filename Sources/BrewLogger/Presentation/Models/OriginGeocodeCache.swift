//
//  OriginGeocodeCache.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/26/26.
//

import CoreLocation
import Foundation

// Persists geocoded origin coordinates so MKGeocodingRequest isn't rerun (and rate-limited) on every load.
enum OriginGeocodeCache {
    private static let key = "OriginGeocodeCache.coordinatesByLocation"

    static func coordinate(for location: String) -> CLLocationCoordinate2D? {
        guard
            let stored = UserDefaults.standard.dictionary(forKey: key) as? [String: [String: Double]],
            let entry = stored[location],
            let latitude = entry["lat"], let longitude = entry["lon"]
        else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func store(_ coordinate: CLLocationCoordinate2D, for location: String) {
        var stored = UserDefaults.standard.dictionary(forKey: key) as? [String: [String: Double]] ?? [:]
        stored[location] = ["lat": coordinate.latitude, "lon": coordinate.longitude]
        UserDefaults.standard.set(stored, forKey: key)
    }
}
