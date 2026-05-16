//
//  OriginInfo.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import Foundation

public struct OriginInfo: Sendable {
    public let location: String
    public let altitude: Int?
    
    public init(location: String, altitude: Int?) {
        self.location = location
        self.altitude = altitude
    }
}
