//
//  BleScaleUseCases.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/17/26.
//

import Foundation

public struct ConnectToScaleUseCase {
    private let repository: BLEScaleRepository
    
    public init(repository: BLEScaleRepository) { self.repository = repository }
    
    @MainActor public func execute() { repository.connect() }
}

public struct DisconnectFromScaleUseCase {
    private let repository: BLEScaleRepository
    
    public init(repository: BLEScaleRepository) { self.repository = repository }
    
    @MainActor public func execute() { repository.disconnect() }
}

public struct ObserveScaleReadingsUseCase {
    private let repository: BLEScaleRepository
    
    public init(repository: BLEScaleRepository) { self.repository = repository }
    
    @MainActor public func execute() -> AsyncStream<ScaleReading> { repository.readings }
}
public struct ObserveScaleStateUseCase {
    private let repository: BLEScaleRepository
    
    public init(repository: BLEScaleRepository) { self.repository = repository }
    
    @MainActor public func execute() -> AsyncStream<BLEConnectionState> { repository.state​Changes }
}

public struct TareScaleUseCase {
    private let repository: BLEScaleRepository
    
    public init(repository: BLEScaleRepository) { self.repository = repository }
    
    @MainActor public func execute() { repository.tare() }
}

