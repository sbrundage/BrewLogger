//
//  BrewRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 1/3/26.
//

import Foundation

public protocol BrewRepository {
    func log(_ brew: Brew) throws
    func fetch(for brewId: String) throws -> Brew?
    func fetchAll(for coffeeId: String?) throws -> [Brew]
    func delete(id: String) throws
    func update(_ brew: Brew) throws
}
