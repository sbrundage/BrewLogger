//
//  BLEScaleRepository.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/5/26.
//

import Foundation

@MainActor
public protocol BLEScaleRepository: AnyObject {
    var connectionState: BLEConnectionState { get }
    var state​Changes: AsyncStream<BLEConnectionState> { get }
    var readings: AsyncStream<ScaleReading> { get }
    func connect()
    func disconnect()
    func tare()
}
