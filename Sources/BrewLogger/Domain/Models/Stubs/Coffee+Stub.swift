//
//  Coffee+Stub.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation

public extension Coffee {
    // Roast dates are spread across the RoastFreshness bands (fresh ≤21d, good ≤45d, stale beyond).
    private static func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
    }

    static let preview = Coffee(
        id: UUID().uuidString,
        name: "Rodrigo Sanchez",
        originInfo: .init(location: "Huila, Colombia", altitude: 1730, latitude: 2.5359, longitude: -75.5277, canonicalName: "Huila, Colombia"),
        roastInfo: .init(roaster: "KOS", date: daysAgo(12), roastLevel: .light),
        process: .natural,
        variety: nil,
        finishedAt: nil
    )

    static let previewList: [Coffee] = [
        Coffee(
            id: UUID().uuidString,
            name: "Rodrigo Sanchez",
            originInfo: .init(location: "Huila, Colombia", altitude: 1730, latitude: 2.5359, longitude: -75.5277, canonicalName: "Huila, Colombia"),
            roastInfo: .init(roaster: "KOS", date: daysAgo(2), roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "El Puente",
            originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: nil, roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "Guatemala",
            originInfo: .init(location: "La Union Zacapa, Guatemala", altitude: 1500, latitude: 14.9667, longitude: -89.2833, canonicalName: "Zacapa, Guatemala"),
            roastInfo: .init(roaster: "KOS", date: daysAgo(12), roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "Andrews Cardona",
            originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: daysAgo(25), roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "Koke Washing Station",
            originInfo: .init(location: "Yirgacheffe, Ethiopia", altitude: 1850, latitude: 6.1667, longitude: 38.2059, canonicalName: "Yirgacheffe, Ethiopia"),
            roastInfo: .init(roaster: "KOS", date: nil, roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "Strawberry Shake",
            originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: daysAgo(45), roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "Ana Maria Donneys",
            originInfo: nil,
            roastInfo: .init(roaster: "Prarie House", date: daysAgo(72), roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
        Coffee(
            id: UUID().uuidString,
            name: "Drop Bear Espresso",
            originInfo: nil,
            roastInfo: .init(roaster: "Kookaburra", date: nil, roastLevel: .light),
            process: nil,
            variety: nil,
            finishedAt: nil
        ),
    ]
}
