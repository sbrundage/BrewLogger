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
    // AsyncStream terminates when its consuming task is cancelled, making it single-use.
    // To support multiple sequential subscribers (e.g. a modal being dismissed and re-opened),
    // we use a multicast pattern: each call to readings/stateChanges creates a fresh AsyncStream
    // with its own continuation. We keep a dictionary of active continuations and yield to all of
    // them whenever the BLE hardware fires. When a subscriber's task is cancelled, its continuation
    // removes itself from the dictionary via onTermination.
    private var readingsContinuations: [UUID: AsyncStream<ScaleReading>.Continuation] = [:]
    private var stateContinuations: [UUID: AsyncStream<BLEConnectionState>.Continuation] = [:]

    /// Live scale readings (weight + env data) emitted on each BLE notify callback.
    /// Each call returns a fresh stream — safe to iterate across multiple sequential consumers.
    var readings: AsyncStream<ScaleReading> {
        let id = UUID()
        return AsyncStream { [weak self] continuation in
            self?.readingsContinuations[id] = continuation
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.readingsContinuations.removeValue(forKey: id)
                }
            }
        }
    }

    /// Connection state transitions emitted whenever the BLE state machine advances.
    /// Each call returns a fresh stream — safe to iterate across multiple sequential consumers.
    var stateChanges: AsyncStream<BLEConnectionState> {
        let id = UUID()
        return AsyncStream { [weak self] continuation in
            self?.stateContinuations[id] = continuation
            continuation.onTermination = { @Sendable [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.stateContinuations.removeValue(forKey: id)
                }
            }
        }
    }

    private(set) var connectionState: BLEConnectionState = .disconnected

    private var centralManager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var tareCharacteristic: CBCharacteristic?
    private var latestTemperature: Double = 0
    private var latestHumidity: Double = 0

    override init() {
        super.init()
    }

    // MARK: - Public interface

    func connect() {
        guard centralManager == nil else { return }
        // Initialising CBCentralManager triggers centralManagerDidUpdateState(_:).
        // queue: .main keeps all delegate callbacks on the main thread, consistent with @MainActor.
        connectionState = .scanning
        stateContinuations.values.forEach { $0.yield(.scanning) }
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
        stateContinuations.values.forEach { $0.yield(.disconnected) }
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
        stateContinuations.values.forEach { $0.yield(.connecting) }
        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectionState = .connected
        stateContinuations.values.forEach { $0.yield(.connected) }
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
        stateContinuations.values.forEach { $0.yield(.scanning) }
        central.scanForPeripherals(withServices: [envServiceUUID, scaleServiceUUID])
    }

    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: (any Error)?
    ) {
        if let error {
            connectionState = .failed(error)
            stateContinuations.values.forEach { $0.yield(.failed(error)) }
        } else {
            connectionState = .disconnected
            stateContinuations.values.forEach { $0.yield(.disconnected) }
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
            readingsContinuations.values.forEach { $0.yield(reading) }

        default:
            break
        }
    }
}
