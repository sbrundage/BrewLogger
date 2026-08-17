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
    public let finishedAt: Date?

    public var hasDetails: Bool { originInfo != nil || roastInfo != nil || process != nil }
    public var isFinished: Bool { finishedAt != nil }

    public init(
        id: String,
        name: String,
        originInfo: OriginInfo?,
        roastInfo: RoastInfo?,
        process: ProcessMethod?,
        variety: String?,
        finishedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.originInfo = originInfo
        self.roastInfo = roastInfo
        self.process = process
        self.variety = variety
        self.finishedAt = finishedAt
    }

    public static func == (lhs: Coffee, rhs: Coffee) -> Bool { lhs.id == rhs.id }

    public func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

// MARK: Helpers

public extension Coffee {
    func withOrigin(_ originInfo: OriginInfo?) -> Coffee {
        Coffee(
            id: id,
            name: name,
            originInfo: originInfo,
            roastInfo: roastInfo,
            process: process,
            variety: variety,
            finishedAt: finishedAt
        )
    }

    // Pass nil to reopen (clear the finished flag).
    func markingFinished(_ date: Date?) -> Coffee {
        Coffee(
            id: id,
            name: name,
            originInfo: originInfo,
            roastInfo: roastInfo,
            process: process,
            variety: variety,
            finishedAt: date
        )
    }

    // Opening a fresh bag: stamp the new roast date and reactivate the coffee.
    func openingBag(roastedAt date: Date) -> Coffee {
        Coffee(
            id: id,
            name: name,
            originInfo: originInfo,
            roastInfo: RoastInfo(
                roaster: roastInfo?.roaster,
                date: date,
                roastLevel: roastInfo?.roastLevel
            ),
            process: process,
            variety: variety,
            finishedAt: nil
        )
    }
}
