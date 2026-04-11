//
//  BLEConnectionState.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/5/26.
//

import Foundation

public enum BLEConnectionState: Sendable {
    case disconnected
    case scanning
    case connecting
    case connected
    case failed(any Error)
}
