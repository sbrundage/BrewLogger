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
    private var armTask: Task<Void, Never>?

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
        armTask?.cancel()
        isArmed = false
        resetSession()
    }

    public func tare() {
        guard !isArmed else { return }
        resetSession()
        tareUseCase.execute()
        // Delay arming so readings at the pre-tare weight are discarded while
        // the ESP32 processes the tare command (~100ms loop interval + margin).
        armTask?.cancel()
        armTask = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(400))
                self?.isArmed = true
            } catch {
                // Task was cancelled before firing — do not arm
            }
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

        // Hard stop at max brew time — prevents chart overflow
        if elapsed >= 40 {
            finalYield = samples.last?.weight ?? reading.weight
            isArmed = false
            return
        }

        samples.append(WeightSample(elapsed: elapsed, weight: reading.weight))
        
//        detectFinalYield()
    }

    func detectFinalYield() {
        guard finalYield == nil, let latest = samples.last else { return }
        // Don't check until well into the shot to avoid false positives during pre-infusion
        guard latest.weight > 15, latest.elapsed >= 12 else { return }

        // Find the sample from ~4 seconds ago using elapsed time in the samples
        let windowStart = latest.elapsed - 4.0
        guard let oldSample = samples.first(where: { $0.elapsed >= windowStart }) else { return }

        // Active extraction runs ~1–2 g/s; threshold is 2g/4s = 0.5 g/s.
        // If weight increased by less than 2g in the last 4 seconds, the shot is done.
        let increase = latest.weight - oldSample.weight
        if increase < 2.0 {
            finalYield = latest.weight
            isArmed = false
        }
    }
}

struct WeightSample: Identifiable {
    let id = UUID()
    let elapsed: Double
    let weight: Double
}
