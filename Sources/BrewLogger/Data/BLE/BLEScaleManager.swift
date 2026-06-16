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
    // An AsyncStream dies when its consuming task is cancelled, so each call to readings/stateChanges
    // returns a fresh stream + continuation. Continuations are keyed by UUID so a consumer can come
    // and go across view transitions: onTermination removes only that consumer's entry, so a stale
    // cleanup can't clobber a newly-subscribed one (onTermination fires asynchronously). BLE callbacks
    // yield to every active continuation.
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
    // Temp/humidity arrive on their own characteristics; we cache the latest of each so a weight
    // notify can bundle all three into a single ScaleReading.
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
        // User-initiated teardown: cancel the connection and clear all handles. We set .disconnected
        // here rather than waiting on didDisconnectPeripheral, which auto-resumes scanning.
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

// Connection flow: didUpdateState → scan → didDiscover (match name) → connect →
// didConnect → discover services. Each step also yields the new state to subscribers.
extension BLEScaleManager: @preconcurrency CBCentralManagerDelegate {

    // Central is only usable once powered on; that callback kicks off the initial scan.
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
        // Only our named peripheral; ignore everything else the scan surfaces.
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
        // Become the peripheral's delegate, then walk services → characteristics.
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

// Characteristic flow: didDiscoverServices → discover characteristics → subscribe to NOTIFY chars
// → didUpdateValueFor fires on every reading.
extension BLEScaleManager: @preconcurrency CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard let services = peripheral.services else { return }
        // Discover all characteristics on each service (pass nil = no filter).
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
            // Subscribe to anything that notifies (weight, temp, humidity) → didUpdateValueFor.
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

        // ESP32 sends fixed-point ints; divide back to real units (see CLAUDE.md encoding notes).
        switch characteristic.uuid {
        case temperatureCharUUID:
            let raw = data.withUnsafeBytes { $0.load(as: Int16.self) }
            latestTemperature = Double(raw) / 100.0   // °F ×100

        case humidityCharUUID:
            let raw = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            latestHumidity = Double(raw) / 100.0      // % ×100

        case weightCharUUID:
            // Weight notifies at 10 Hz — the cadence that drives a live reading. Bundle the cached
            // temp/humidity in and broadcast to subscribers.
            let raw = data.withUnsafeBytes { $0.load(as: Int16.self) }
            let weight = Double(raw) / 10.0           // grams ×10
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
