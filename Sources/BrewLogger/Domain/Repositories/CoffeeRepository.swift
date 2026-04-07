//
//  CoffeeRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation

public protocol CoffeeRepository {
    func log(_ coffee: Coffee) throws
    func fetchAll() throws -> [Coffee]
    func delete(id: String) throws
    func update(_ brew: Coffee) throws
}
