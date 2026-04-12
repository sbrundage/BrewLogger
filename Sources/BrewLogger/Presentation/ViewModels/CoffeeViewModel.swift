//
//  CoffeeViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 3/22/26.
//

import Foundation
import BrewLoggerDomain

@MainActor @Observable
public class CoffeeViewModel {
    private(set) var coffees: [Coffee] = []

    public init() {}
}
