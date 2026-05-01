//
//  Coffee+Stub.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation

public extension Coffee {
    static let preview = Coffee(
        name: "Rodrigo Sanchez",
        originInfo: .init(location: "Huila, Colombia", altitude: 1730),
        roastInfo: .init(roaster: "KOS", date: Date(), roastLevel: .light),
        process: .natural
    )

    static let previewList: [Coffee] = [
        Coffee(name: "Rodrigo Sanchez", originInfo: .init(location: "Huila, Colombia", altitude: 1730), roastInfo: .init(roaster: "KOS", date: Date(), roastLevel: .light), process: nil),
        Coffee(name: "El Puente", originInfo: nil, roastInfo: .init(roaster: "KOS", date: nil, roastLevel: .light), process: nil),
        Coffee(name: "Guatemala", originInfo: .init(location: "La Union Zacapa, Guatemala", altitude: 1500), roastInfo: .init(roaster: "KOS", date: Date(), roastLevel: .light), process: nil),
        Coffee(name: "Andrews Cardona", originInfo: nil, roastInfo: .init(roaster: "KOS", date: Date(), roastLevel: .light), process: nil),
        Coffee(name: "Koke Washing Station", originInfo: .init(location: "Yirgacheffe, Ethiopia", altitude: 1850), roastInfo: .init(roaster: "KOS", date: nil, roastLevel: .light), process: nil),
        Coffee(name: "Strawberry Shake", originInfo: nil, roastInfo: .init(roaster: "KOS", date: Date(), roastLevel: .light), process: nil),
        Coffee(name: "Ana Maria Donneys", originInfo: nil, roastInfo: .init(roaster: "Prarie House", date: Date(), roastLevel: .light), process: nil),
        Coffee(name: "Drop Bear Espresso", originInfo: nil, roastInfo: .init(roaster: "Kookaburra", date: nil, roastLevel: .light), process: nil),
    ]
}
