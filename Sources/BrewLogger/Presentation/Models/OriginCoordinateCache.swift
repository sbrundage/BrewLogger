//
//  OriginCoordinateCache.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/26/26.
//

import CoreLocation
import Foundation

// Abstraction the ViewModel depends on; production uses UserDefaults, tests use a stub.
protocol OriginCoordinateCache {
    func coordinate(for location: String) -> CLLocationCoordinate2D?
    func save(_ coordinate: CLLocationCoordinate2D, for location: String)
}

// Persistence seam so the cache can be tested with an in-memory fake instead of UserDefaults.
protocol KeyValueStore {
    func dictionary(forKey key: String) -> [String: Any]?
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStore {}

// Caches geocoded origin coordinates so MKGeocodingRequest isn't rerun (and rate-limited) on every load.
final class UserDefaultsOriginCoordinateCache: OriginCoordinateCache {
    private static let storageKey = "OriginCoordinateCache.coordinatesByLocation"

    private let store: KeyValueStore

    private var coordinatesByLocation: [String: CLLocationCoordinate2D]

    init(store: KeyValueStore = UserDefaults.standard) {
        self.store = store
        self.coordinatesByLocation = Self.decode(store.dictionary(forKey: Self.storageKey))
    }

    func coordinate(for location: String) -> CLLocationCoordinate2D? {
        coordinatesByLocation[location]
    }

    func save(_ coordinate: CLLocationCoordinate2D, for location: String) {
        coordinatesByLocation[location] = coordinate
        store.set(Self.encode(coordinatesByLocation), forKey: Self.storageKey)
    }

    private static func decode(_ raw: [String: Any]?) -> [String: CLLocationCoordinate2D] {
        guard let raw = raw as? [String: [String: Double]] else { return [:] }
        return raw.reduce(into: [:]) { result, entry in
            guard let latitude = entry.value["lat"], let longitude = entry.value["lon"] else { return }
            result[entry.key] = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    private static func encode(_ coordinates: [String: CLLocationCoordinate2D]) -> [String: [String: Double]] {
        coordinates.mapValues { ["lat": $0.latitude, "lon": $0.longitude] }
    }
}
