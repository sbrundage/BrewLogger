//
//  Coffee.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/16/26.
//

import Foundation

public struct Coffee: Sendable, Identifiable {
    public let id: String
    public let name: String
    public let originInfo: OriginInfo?
    public let roastInfo: RoastInfo?
    public let brews: [Brew]
    public let process: ProcessMethod?

    public init(
        id: String = UUID().uuidString,
        name: String,
        originInfo: OriginInfo?,
        roastInfo: RoastInfo?,
        brews: [Brew],
        process: ProcessMethod?
    ) {
        self.id = id
        self.name = name
        self.originInfo = originInfo
        self.roastInfo = roastInfo
        self.brews = brews
        self.process = process
    }
}

public enum ProcessMethod: Sendable {
    case washed
    case natural
    case honey
    case other(String)
}
