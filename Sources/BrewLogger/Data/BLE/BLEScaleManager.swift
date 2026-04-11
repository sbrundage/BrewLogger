//
//  BLEScaleManager.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/5/26.
//

import CoreBluetooth
import BrewLoggerDomain

@MainActor
final class BLEScaleManager: NSObject {
    // BLE UUIDs
    private let envServiceUUID      = CBUUID(string: "181A")
    private let temperatureCharUUID = CBUUID(string: "2A6E")
    private let humidityCharUUID    = CBUUID(string: "2A6F")
    private let scaleServiceUUID    = CBUUID(string: "12345678-1234-1234-1234-1234567890AB")
    private let weightCharUUID      = CBUUID(string: "12345678-1234-1234-1234-1234567890AC")

    private let continuation: AsyncStream<ScaleReading>.Continuation

    private(set) var connectionState: BLEConnectionState = .disconnected

    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var latestTemperature: Double = 0
    private var latestHumidity: Double = 0

    let readings: AsyncStream<ScaleReading>

    override init() {
        var cont: AsyncStream<ScaleReading>.Continuation!
        readings = AsyncStream { cont = $0 }
        continuation = cont
        super.init()
    }

    // MARK: - Public interface

    func connect() {
        guard centralManager == nil else { return }
        connectionState = .scanning
        // queue: .main ensures all delegate callbacks arrive on the main thread,
        // which is safe since this class is @MainActor
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func disconnect() {
        if let peripheral, let centralManager {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        continuation.finish()
        connectionState = .disconnected
        peripheral = nil
        centralManager = nil
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEScaleManager: @preconcurrency CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        central.scanForPeripherals(withServices: [envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        guard peripheral.name == "Coffee Scale" else { return }
        self.peripheral = peripheral
        central.stopScan()
        connectionState = .connecting
        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        peripheral.delegate = self
        peripheral.discoverServices([envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        self.peripheral = nil
        connectionState = .scanning
        // Automatically restart scan to reconnect
        central.scanForPeripherals(withServices: [envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        if let error {
            connectionState = .failed(error)
        }
    }
}

// MARK: - CBPeripheralDelegate

extension BLEScaleManager: @preconcurrency CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: (any Error)?
    ) {
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics where characteristic.properties.contains(.notify) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: (any Error)?
    ) {
        guard error == nil, let data = characteristic.value else { return }

        switch characteristic.uuid {
        case temperatureCharUUID:
            let raw = data.withUnsafeBytes { $0.load(as: Int16.self) }
            latestTemperature = Double(raw) / 100.0

        case humidityCharUUID:
            let raw = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            latestHumidity = Double(raw) / 100.0

        case weightCharUUID:
            let raw = data.withUnsafeBytes { $0.load(as: Int16.self) }
            let weight = Double(raw) / 10.0
            let reading = ScaleReading(
                weight: weight,
                temperature: latestTemperature,
                humidity: latestHumidity
            )
            continuation.yield(reading)

        default:
            break
        }
    }
}
