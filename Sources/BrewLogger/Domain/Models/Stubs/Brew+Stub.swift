//
//  Brew+Stub.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/10/26.
//

import Foundation

public extension Brew {
    static let preview = Brew(
        id: UUID().uuidString,
        date: Date(),
        coffee: Coffee.preview,
        grindSize: 0.6,
        dose: 18.0,
        yield: 36.0,
        brewTime: 28,
        method: .pourOver,
        brewTemp: 195,
        roastDate: Date().addingTimeInterval(-86400 * 12),
        tastingEntries: [
            TastingEntry(createdAt: Date(), rating: 4, note: "Clean and sweet, nice clarity"),
            TastingEntry(createdAt: Date().addingTimeInterval(8 * 60), rating: 4.5, note: "Acidity opening up, juicy"),
            TastingEntry(createdAt: Date().addingTimeInterval(16 * 60), rating: 3.5, note: "Flattening as it cools")
        ]
    )

    /*
     Note:
     Tests for BrewListViewModel use this array so changes to this may cause failures.
     */
    static let previewList: [Brew] = [
        Brew(
            id: UUID().uuidString,
            date: Date(),
            coffee: Coffee.previewList[0],
            grindSize: 0.6,
            dose: 18.0,
            yield: 36.0,
            brewTime: 28,
            method: .pourOver,
            brewTemp: 195,
            roastDate: Date().addingTimeInterval(-86400 * 12),
            tastingEntries: [TastingEntry(createdAt: Date(), rating: 4, note: "Clean and sweet, nice clarity")]
        ),
        Brew(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-86400),
            coffee: Coffee.previewList[0],
            grindSize: 0.6,
            dose: 18.5,
            yield: 37.0,
            brewTime: 30,
            method: .pourOver,
            brewTemp: 195,
            roastDate: Date().addingTimeInterval(-86400 * 12),
            tastingEntries: [TastingEntry(createdAt: Date().addingTimeInterval(-86400), rating: 3, note: "Slightly over-extracted, bitter finish")]
        ),
        Brew(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-86400 * 2),
            coffee: Coffee.previewList[1],
            grindSize: 0.6,
            dose: 17.0,
            yield: 34.0,
            brewTime: 26,
            method: .espresso,
            brewTemp: 195,
            roastDate: Date().addingTimeInterval(-86400 * 12),
            tastingEntries: [TastingEntry(createdAt: Date().addingTimeInterval(-86400 * 2), rating: 5, note: "Best shot yet")]
        ),
        Brew(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-86400 * 3),
            coffee: Coffee.previewList[1],
            grindSize: 0.6,
            dose: 17.0,
            yield: 35.0,
            brewTime: 27,
            method: .espresso,
            brewTemp: 195,
            roastDate: Date().addingTimeInterval(-86400 * 12),
            tastingEntries: [TastingEntry(createdAt: Date().addingTimeInterval(-86400 * 3), rating: 4, note: "")]
        ),
        Brew(
            id: UUID().uuidString,
            date: Date().addingTimeInterval(-86400 * 5),
            coffee: Coffee.previewList[2],
            grindSize: 0.6,
            dose: 20.0,
            yield: 40.0,
            brewTime: 32,
            method: .pourOver,
            brewTemp: 195,
            roastDate: Date().addingTimeInterval(-86400 * 12),
            tastingEntries: [TastingEntry(createdAt: Date().addingTimeInterval(-86400 * 5), rating: 3, note: "Under-developed, needs coarser grind")]
        ),
    ]
}
