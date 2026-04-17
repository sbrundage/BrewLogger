//
//  Listable.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/14/26.
//

import Foundation
import BrewLoggerDomain

protocol Listable: Identifiable, Equatable {
    var title: String { get }
}

extension Coffee: Listable {
    var title: String { name }
}

extension BrewMethod: Listable {}
