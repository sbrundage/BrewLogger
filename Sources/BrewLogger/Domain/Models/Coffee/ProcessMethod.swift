//
//  ProcessMethod.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import Foundation

public enum ProcessMethod: String, Sendable, Hashable, CaseIterable {
    case washed
    case natural
    case honey
    case wetHulled = "wet hulled"
}
