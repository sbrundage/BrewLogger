//
//  BleScaleViewModel.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/17/26.
//

import Foundation
import BrewLoggerApplication
import BrewLoggerDomain

@MainActor @Observable
public final class BleScaleConnectionManager {
    public private(set) var connectionState: BLEConnectionState = .disconnected

    private let connect: ConnectToScaleUseCase
    private let disconnect: DisconnectFromScaleUseCase
    private let observeState: ObserveScaleStateUseCase
    private var stateTask: Task<Void, Never>?

    public init(repository: BLEScaleRepository = RepositoryFactory.stub.scale) {
        self.connect = ConnectToScaleUseCase(repository: repository)
        self.disconnect = DisconnectFromScaleUseCase(repository: repository)
        self.observeState = ObserveScaleStateUseCase(repository: repository)
    }

    public func startConnecting() {
        connect.execute()
        stateTask = Task { [weak self] in
            guard let self else { return }
            for await state in observeState.execute() {
                self.connectionState = state
            }
        }
    }

    public func stopConnecting() {
        stateTask?.cancel()
        disconnect.execute()
    }
}

@MainActor @Observable
public final class BleScaleViewModel {
    private let connect: ConnectToScaleUseCase
    private let disconnect: DisconnectFromScaleUseCase
    private let observe: ObserveScaleReadingsUseCase
    private let observeState: ObserveScaleStateUseCase
    private let tareUseCase: TareScaleUseCase

    private(set) var connectionState: BLEConnectionState = .disconnected
    private(set) var latestReading: ScaleReading?
    // Two tasks so each stream is observed independently —
    // a weight update won't block a connection state update.
    private var readingsTask: Task<Void, Never>?
    private var stateTask: Task<Void, Never>?

    public init(repository: BLEScaleRepository = RepositoryFactory.stub.scale) {
        self.connect = ConnectToScaleUseCase(repository: repository)
        self.disconnect = DisconnectFromScaleUseCase(repository: repository)
        self.observe = ObserveScaleReadingsUseCase(repository: repository)
        self.observeState = ObserveScaleStateUseCase(repository: repository)
        self.tareUseCase = TareScaleUseCase(repository: repository)
    }

    public func startConnecting() {
        connect.execute()
        
        readingsTask = Task { [weak self] in
            guard let self else { return }
            for await reading in observe.execute() {
                self.latestReading = reading
                print("Scale reading — weight: \(reading.weight)g, temp: \(reading.temperature), humidity: \(reading.humidity)")
            }
        }
        
        stateTask = Task { [weak self] in
            guard let self else { return }
            for await state in observeState.execute() {
                self.connectionState = state
                print("BLE state: \(state)") // temporary
            }
        }
    }

    public func stopConnecting() {
        readingsTask?.cancel()
        stateTask?.cancel()
        disconnect.execute()
    }

    public func tare() {
        tareUseCase.execute()
    }
}
