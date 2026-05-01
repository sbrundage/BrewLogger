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

    public init(
        id: String = UUID().uuidString,
        name: String,
        originInfo: OriginInfo?,
        roastInfo: RoastInfo?,
        process: ProcessMethod?
    ) {
        self.id = id
        self.name = name
        self.originInfo = originInfo
        self.roastInfo = roastInfo
        self.process = process
    }
    
    public static func == (lhs: Coffee, rhs: Coffee) -> Bool { lhs.id == rhs.id }
    
    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

public enum ProcessMethod: String, Sendable, Hashable {
    case washed
    case natural
    case honey
    case wetHulled = "wet hulled"
}
