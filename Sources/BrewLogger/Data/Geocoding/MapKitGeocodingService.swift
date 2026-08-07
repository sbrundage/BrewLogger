//
//  MapKitGeocodingService.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/4/26.
//

import MapKit
import BrewLoggerDomain

public struct MapKitGeocodingService: GeocodingService {
    public init() {}

    public func geocode(_ query: String) async -> GeocodeResult? {
        guard
            let request = MKGeocodingRequest(addressString: query),
            let mapItems = try? await request.mapItems,
            let item = mapItems.first
        else { return nil }

        let coordinate = item.location.coordinate
        return GeocodeResult(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            canonicalName: item.name
        )
    }
}
