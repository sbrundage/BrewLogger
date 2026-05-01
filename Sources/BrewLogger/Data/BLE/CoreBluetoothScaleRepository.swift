//
//  CoreBluetoothScaleRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/5/26.
//

import Foundation
import BrewLoggerDomain

@MainActor @Observable
public final class CoreBluetoothScaleRepository: BLEScaleRepository {
    private let manager: BLEScaleManager

    public init() {
        self.manager = BLEScaleManager()
    }

    public var connectionState: BLEConnectionState { manager.connectionState }
    public var state​Changes: AsyncStream<BLEConnectionState> { manager.stateChanges }
    public var readings: AsyncStream<ScaleReading> { manager.readings }

    public func connect() { manager.connect() }
    public func disconnect() { manager.disconnect() }
    public func tare() { manager.tare() }
}
