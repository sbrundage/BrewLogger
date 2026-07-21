//
//  BrewTimerTextField+VM.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/23/26.
//

import Foundation

extension BrewTimerTextField {
    @Observable
    @MainActor
    final class ViewModel {
        private var timerTask: Task<Void, Never>?
        private var startDate: Date = .now

        private(set) var isRunning: Bool = false
        private(set) var time: Double = 0.0
        private(set) var brewTimeString: String = ""
        private(set) var showResetButton = false
        private(set) var stoppedAt: Date?

        func formatted(_ seconds: Double) -> String {
            let m = Int(seconds) / 60
            let s = Int(seconds) % 60
            let t = Int((seconds.truncatingRemainder(dividingBy: 1) * 10).rounded())
            return String(format: "%d:%02d.%d", m, s, t)
        }

        func start() {
            showResetButton = false
            startDate = Date().addingTimeInterval(-time)
            isRunning = true
            timerTask = Task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .milliseconds(100))
                    guard !Task.isCancelled else { break }
                    self.time = Date().timeIntervalSince(self.startDate)
                    self.brewTimeString = String(format: "%.1f", self.time)
                }
            }
        }

        func pause() {
            guard isRunning else { return }
            timerTask?.cancel()
            timerTask = nil
            isRunning = false
            time = Date().timeIntervalSince(startDate)
            brewTimeString = String(format: "%.1f", time)
            showResetButton = true
            stoppedAt = Date()
        }

        func reset() {
            pause()
            time = 0
            brewTimeString = ""
            showResetButton = false
            stoppedAt = nil
        }
    }
}
