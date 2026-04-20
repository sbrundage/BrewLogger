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
    // MARK: - Constants
    private static let peripheralName = "Coffee Scale"

    // MARK: - BLE UUIDs
    // Standard Bluetooth SIG UUIDs for environmental sensing (temp/humidity)
    private let envServiceUUID      = CBUUID(string: "181A")
    private let temperatureCharUUID = CBUUID(string: "2A6E")
    private let humidityCharUUID    = CBUUID(string: "2A6F")
    // Custom UUIDs defined on the ESP32 for scale weight data
    private let scaleServiceUUID    = CBUUID(string: "12345678-1234-1234-1234-1234567890AB")
    private let weightCharUUID      = CBUUID(string: "12345678-1234-1234-1234-1234567890AC")
    // Write-only characteristic — write any byte to trigger a tare on the ESP32
    private let tareCharUUID        = CBUUID(string: "12345678-1234-1234-1234-1234567890AD")

    // MARK: - AsyncStream infrastructure
    // Each stream has a paired continuation — the continuation is the write-end (yield/finish),
    // the stream is the read-end consumed by observers. Both are created once in init and kept alive
    // for the lifetime of this manager.
    private let readingsContinuation: AsyncStream<ScaleReading>.Continuation
    private let stateContinuation: AsyncStream<BLEConnectionState>.Continuation

    /// Live scale readings (weight + env data) emitted on each BLE notify callback.
    let readings: AsyncStream<ScaleReading>
    /// Connection state transitions emitted whenever the BLE state machine advances.
    let stateChanges: AsyncStream<BLEConnectionState>

    private(set) var connectionState: BLEConnectionState = .disconnected

    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var tareCharacteristic: CBCharacteristic?
    private var latestTemperature: Double = 0
    private var latestHumidity: Double = 0

    override init() {
        var readingsCont: AsyncStream<ScaleReading>.Continuation!
        readings = AsyncStream { readingsCont = $0 }
        readingsContinuation = readingsCont

        var stateCont: AsyncStream<BLEConnectionState>.Continuation!
        stateChanges = AsyncStream { stateCont = $0 }
        stateContinuation = stateCont

        super.init()
    }

    // MARK: - Public interface

    func connect() {
        guard centralManager == nil else { return }
        // Initialising CBCentralManager triggers centralManagerDidUpdateState(_:).
        // queue: .main keeps all delegate callbacks on the main thread, consistent with @MainActor.
        connectionState = .scanning
        stateContinuation.yield(.scanning)
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }

    func tare() {
        guard let peripheral, let tareCharacteristic else { return }
        // Write a single byte — the ESP32 TareCallbacks::onWrite triggers scale.tare() on any write
        peripheral.writeValue(Data([0x01]), for: tareCharacteristic, type: .withResponse)
    }

    func disconnect() {
        if let peripheral, let centralManager {
            centralManager.cancelPeripheralConnection(peripheral)
        }
        connectionState = .disconnected
        stateContinuation.yield(.disconnected)
        // Do NOT finish the streams here — finishing permanently kills them.
        // Since RepositoryFactory.dev is a singleton, the same streams are reused
        // across connect/disconnect cycles. Tasks that observe these streams are
        // cancelled by the view model, so no cleanup is needed on the stream itself.
        peripheral = nil
        tareCharacteristic = nil
        centralManager = nil
    }
}

// MARK: - CBCentralManagerDelegate

extension BLEScaleManager: @preconcurrency CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // TODO: Handle non-poweredOn states (.poweredOff, .unauthorized, .unsupported) by
        // surfacing a .failed or dedicated .bluetoothUnavailable state to the UI.
        guard central.state == .poweredOn else { return }
        central.scanForPeripherals(withServices: [envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi: NSNumber
    ) {
        guard peripheral.name == BLEScaleManager.peripheralName else { return }
        self.peripheral = peripheral
        central.stopScan()
        connectionState = .connecting
        stateContinuation.yield(.connecting)
        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        stateContinuation.yield(.connected)
        peripheral.delegate = self
        peripheral.discoverServices([envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        self.peripheral = nil
        // Peripheral dropped — resume scanning to auto-reconnect
        connectionState = .scanning
        stateContinuation.yield(.scanning)
        central.scanForPeripherals(withServices: [envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        if let error {
            connectionState = .failed(error)
            stateContinuation.yield(.failed(error))
        } else {
            connectionState = .disconnected
            stateContinuation.yield(.disconnected)
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
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: characteristic)
            }
            // Store tare characteristic so tare() can write to it later
            if characteristic.uuid == tareCharUUID {
                tareCharacteristic = characteristic
            }
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
            readingsContinuation.yield(reading)

        default:
            break
        }
    }
}
