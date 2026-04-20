//
//  BleScaleConnectionManager.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/19/26.
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

    var isConnected: Bool { connectionState == .connected }

    public init(repository: BLEScaleRepository = RepositoryFactory.dev.scale) {
        self.connect = ConnectToScaleUseCase(repository: repository)
        self.disconnect = DisconnectFromScaleUseCase(repository: repository)
        self.observeState = ObserveScaleStateUseCase(repository: repository)
        self.connectionState = repository.connectionState
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
