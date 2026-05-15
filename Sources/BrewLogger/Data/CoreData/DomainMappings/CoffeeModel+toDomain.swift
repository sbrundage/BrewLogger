//
//  CoffeeModel+toDomain.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation
import BrewLoggerDomain

extension CoffeeModel {
    func update(from coffee: Coffee) {
        self.id = coffee.id
        self.name = coffee.name
        self.originLocation = coffee.originInfo?.location
        self.originAltitude = coffee.originInfo?.altitude.map { NSNumber(value: $0) }
        self.roaster = coffee.roastInfo?.roaster
        self.roastDate = coffee.roastInfo?.date
        self.roastLevel = coffee.roastInfo?.roastLevel?.rawValue
        self.process = coffee.process?.rawValue
    }

    func toDomain() -> Coffee? {
        guard let id, let name else { return nil }

        let originInfo: OriginInfo? = originLocation.map {
            OriginInfo(location: $0, altitude: originAltitude?.intValue)
        }

        let roastInfo: RoastInfo? = {
            guard roaster != nil || roastDate != nil || roastLevel != nil else { return nil }
            return RoastInfo(
                roaster: roaster,
                date: roastDate,
                roastLevel: roastLevel.flatMap { RoastLevel(rawValue: $0) }
            )
        }()

        return Coffee(
            id: id,
            name: name,
            originInfo: originInfo,
            roastInfo: roastInfo,
            process: process.flatMap { ProcessMethod(rawValue: $0) }
        )
    }
}
