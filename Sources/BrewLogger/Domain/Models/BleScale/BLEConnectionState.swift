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

extension BLEConnectionState: Equatable {
    public static func == (lhs: BLEConnectionState, rhs: BLEConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.scanning, .scanning),
             (.connecting, .connecting),
             (.connected, .connected),
             (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
