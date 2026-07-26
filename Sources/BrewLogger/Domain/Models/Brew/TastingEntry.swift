//
//  TastingEntry.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/23/26.
//

import Foundation

public struct TastingEntry: Codable, Identifiable, Equatable, Sendable {
    public let id: String
    public let createdAt: Date
    public let rating: Double?
    public let note: String

    public init(
        id: String = UUID().uuidString,
        createdAt: Date,
        rating: Double?,
        note: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.rating = rating
        self.note = note
    }
}
