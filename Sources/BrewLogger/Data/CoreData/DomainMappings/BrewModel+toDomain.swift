//
//  BrewModel+initBrew.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/8/26.
//

import Foundation
import CoreData
import BrewLoggerDomain

extension BrewModel {
    func update(from brew: Brew) {
        self.id = brew.id
        self.date = brew.date
        self.grindSize = brew.grindSize
        self.dose = brew.dose
        self.yield = brew.yield
        self.brewTime = brew.brewTime
        self.method = Int16(brew.method.rawValue)
        self.brewTemp = brew.brewTemp.map { NSDecimalNumber(value: $0) }
        self.rating = brew.rating.map { NSDecimalNumber(value: $0) }
        // Legacy `notes` is intentionally left untouched — additive, no data loss.
        self.tastingEntriesData = try? JSONEncoder().encode(brew.tastingEntries)
    }

    func toDomain() -> Brew? {
        guard let id, let date, let domainCoffee = coffee?.toDomain() else { return nil }
        return Brew(
            id: id,
            date: date,
            coffee: domainCoffee,
            grindSize: grindSize,
            dose: dose,
            yield: yield,
            brewTime: brewTime,
            method: BrewMethod(rawValue: Int(method)) ?? .na,
            brewTemp: brewTemp?.intValue,
            rating: rating?.doubleValue,
            tastingEntries: decodedTastingEntries(brewDate: date)
        )
    }

    private func decodedTastingEntries(brewDate: Date) -> [TastingEntry] {
        if let tastingEntriesData,
           let entries = try? JSONDecoder().decode([TastingEntry].self, from: tastingEntriesData),
           !entries.isEmpty {
            return entries
        }
        // One-time backfill: surface a legacy `notes` string as a single entry.
        if let notes, !notes.isEmpty {
            return [TastingEntry(createdAt: brewDate, rating: rating?.doubleValue, note: notes)]
        }
        return []
    }
}
