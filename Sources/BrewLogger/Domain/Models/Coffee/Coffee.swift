//
//  Coffee.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import Foundation

public struct Coffee: Sendable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let originInfo: OriginInfo?
    public let roastInfo: RoastInfo?
    public let process: ProcessMethod?
    public let variety: String?

    public init(
        id: String,
        name: String,
        originInfo: OriginInfo?,
        roastInfo: RoastInfo?,
        process: ProcessMethod?,
        variety: String? = nil
    ) {
        self.id = id
        self.name = name
        self.originInfo = originInfo
        self.roastInfo = roastInfo
        self.process = process
        self.variety = variety
    }
    
    public var hasDetails: Bool { originInfo != nil || roastInfo != nil || process != nil }

    public func withOrigin(_ originInfo: OriginInfo?) -> Coffee {
        Coffee(
            id: id,
            name: name,
            originInfo: originInfo,
            roastInfo: roastInfo,
            process: process,
            variety: variety
        )
    }

    public static func == (lhs: Coffee, rhs: Coffee) -> Bool { lhs.id == rhs.id }

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

