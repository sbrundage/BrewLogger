//
//  RoastInfo.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import Foundation

public struct RoastInfo: Sendable {
    public let roaster: String?
    public let date: Date?
    public let roastLevel: RoastLevel?
    
    public init(
        roaster: String?,
        date: Date?,
        roastLevel: RoastLevel?
    ) {
        self.roaster = roaster
        self.date = date
        self.roastLevel = roastLevel
    }
}

public enum RoastLevel: String, CaseIterable, Sendable {
    case light
    case medium
    case dark
}
