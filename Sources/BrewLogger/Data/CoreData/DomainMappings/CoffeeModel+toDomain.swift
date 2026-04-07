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
        self.roaster = coffee.roastInfo?.roaster
    }

    func toDomain() -> Coffee? {
        guard let id, let name else { return nil }
        let brews = (self.brews as? Set<BrewModel>)?
            .compactMap { $0.toDomain() }
            .sorted { $0.date < $1.date } ?? []
        return .init(
            id: id,
            name: name,
            originInfo: nil,
            roastInfo: .init(roaster: roaster, date: nil, roastLevel: nil),
            brews: brews,
            process: nil
        )
    }
}
