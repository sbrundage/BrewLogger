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
        self.tastingEntriesData = try? JSONEncoder().encode(brew.tastingEntries)
    }

    func toDomain() -> Brew? {
        guard let id, let date, let domainCoffee = coffee?.toDomain() else { return nil }
        let entries = tastingEntriesData
            .flatMap { try? JSONDecoder().decode([TastingEntry].self, from: $0) } ?? []
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
            tastingEntries: entries
        )
    }
}
