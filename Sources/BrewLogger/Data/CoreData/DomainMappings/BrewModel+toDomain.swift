//
//  BrewModel+initBrew.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/8/26.
//

import CoreData
import BrewLoggerDomain

extension BrewModel {
    func update(from brew: Brew) {
        self.id = brew.id
        self.date = brew.date
        self.dose = brew.dose
        self.yield = brew.yield
        self.brewTime = brew.brewTime
        self.method = Int16(brew.method.rawValue)
        self.rating = brew.rating.map { NSDecimalNumber(value: $0) }
        self.notes = brew.notes
    }

    func toDomain() -> Brew? {
        guard let id, let date, let domainCoffee = coffee?.toDomain() else { return nil }
        return Brew(
            id: id,
            date: date,
            coffee: domainCoffee,
            dose: dose,
            yield: yield,
            brewTime: brewTime,
            method: BrewMethod(rawValue: Int(method)) ?? .na,
            rating: rating?.doubleValue,
            notes: notes
        )
    }
}
