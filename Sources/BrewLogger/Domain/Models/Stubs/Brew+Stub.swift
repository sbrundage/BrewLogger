//
//  Brew+Stub.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/10/26.
//

import Foundation

public extension Brew {
    static let preview = Brew(
        date: Date(),
        coffee: Coffee.preview,
        dose: 18.0,
        yield: 36.0,
        brewTime: 28,
        method: .pourOver,
        rating: 4,
        notes: "Clean and sweet, nice clarity"
    )

    static let previewList: [Brew] = [
        Brew(
            date: Date(),
            coffee: Coffee.previewList[0],
            dose: 18.0,
            yield: 36.0,
            brewTime: 28,
            method: .pourOver,
            rating: 4,
            notes: "Clean and sweet, nice clarity"
        ),
        Brew(
            date: Date().addingTimeInterval(-86400),
            coffee: Coffee.previewList[0],
            dose: 18.5,
            yield: 37.0,
            brewTime: 30,
            method: .pourOver,
            rating: 3,
            notes: "Slightly over-extracted, bitter finish"
        ),
        Brew(
            date: Date().addingTimeInterval(-86400 * 2),
            coffee: Coffee.previewList[1],
            dose: 17.0,
            yield: 34.0,
            brewTime: 26,
            method: .espresso,
            rating: 5,
            notes: "Best shot yet"
        ),
        Brew(
            date: Date().addingTimeInterval(-86400 * 3),
            coffee: Coffee.previewList[1],
            dose: 17.0,
            yield: 35.0,
            brewTime: 27,
            method: .espresso,
            rating: 4,
            notes: nil
        ),
        Brew(
            date: Date().addingTimeInterval(-86400 * 5),
            coffee: Coffee.previewList[2],
            dose: 20.0,
            yield: 40.0,
            brewTime: 32,
            method: .pourOver,
            rating: 3,
            notes: "Under-developed, needs coarser grind"
        ),
    ]
}
