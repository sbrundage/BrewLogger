//
//  BrewMethod.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 5/12/26.
//

import SwiftUI

public enum BrewMethod: Int, Sendable, Identifiable {
    case pourOver = 1
    case espresso = 2
    case na = 3
    
    public var image: Image? {
        switch self {
        case .pourOver:
                .init(systemName: "mug")
        case .espresso:
                .init(systemName: "cup.and.saucer")
        case .na: nil
        }
    }
    
    public var title: String {
        switch self {
        case .pourOver:
            "Pour Over"
        case .espresso:
            "Espresso"
        case .na: "N/A"
        }
    }
    
    public var id: Int { rawValue }
}
