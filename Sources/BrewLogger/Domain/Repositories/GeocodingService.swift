//
//  GeocodingService.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 8/4/26.
//

import Foundation

public protocol GeocodingService: Sendable {
    func geocode(_ query: String) async -> GeocodeResult?
}
