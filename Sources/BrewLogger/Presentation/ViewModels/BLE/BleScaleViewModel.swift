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
public final class BleScaleViewModel {
    private let observe: ObserveScaleReadingsUseCase
    private let tareUseCase: TareScaleUseCase

    private(set) var latestReading: ScaleReading?
    private(set) var isArmed: Bool = false
    private(set) var samples: [WeightSample] = []
    private(set) var brewStartTime: Date? = nil
    private(set) var finalYield: Double? = nil

    private var readingsTask: Task<Void, Never>?

    public init(repository: BLEScaleRepository = RepositoryFactory.dev.scale) {
        self.observe = ObserveScaleReadingsUseCase(repository: repository)
        self.tareUseCase = TareScaleUseCase(repository: repository)
    }

    public func startObserving() {
        readingsTask = Task { [weak self] in
            guard let self else { return }
            for await reading in observe.execute() {
                latestReading = reading
                processReading(reading)
            }
        }
    }

    public func stopObserving() {
        readingsTask?.cancel()
        isArmed = false
        resetSession()
    }

    public func tare() {
        guard !isArmed else { return }
        resetSession()
        tareUseCase.execute()
        // Delay arming so readings at the pre-tare weight are discarded while
        // the ESP32 processes the tare command (~100ms loop interval + margin).
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            self?.isArmed = true
        }
    }
}

private extension BleScaleViewModel {
    func resetSession() {
        samples = []
        brewStartTime = nil
        finalYield = nil
    }

    func processReading(_ reading: ScaleReading) {
        guard isArmed else { return }
        
        let now = Date()
        // Start tracking after detecting a 0.2 g increase
        if brewStartTime == nil && reading.weight > 0.2 {
            brewStartTime = now
        }
        
        guard let start = brewStartTime else { return }
        
        let elapsed = now.timeIntervalSince(start)
        samples.append(WeightSample(elapsed: elapsed, weight: reading.weight))
        
        if samples.count > 600 { samples.removeFirst() }
        
        detectFinalYield()
    }

    func detectFinalYield() {
        guard finalYield == nil, samples.count >= 20 else { return }
        
        let recent = samples.suffix(20).map(\.weight)
        let spread = (recent.max() ?? 0) - (recent.min() ?? 0)
        let peak = recent.max() ?? 0
        if spread < 0.5 && peak > 10 {
            finalYield = peak
            isArmed = false
        }
    }
}

struct WeightSample: Identifiable {
    let id = UUID()
    let elapsed: Double
    let weight: Double
}
