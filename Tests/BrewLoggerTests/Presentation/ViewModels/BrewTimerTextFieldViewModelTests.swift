//
//  BrewTimerTextFieldViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 6/23/26.
//

@testable import BrewLoggerPresentation
import Testing

@Suite("BrewTimerTextField.ViewModel")
@MainActor
struct BrewTimerTextFieldViewModelTests {

    // MARK: - Initialization

    @Test("Default initialization")
    func whenInitialized_valuesAreDefault() {
        let sut = BrewTimerTextField.ViewModel()
        #expect(!sut.isRunning)
        #expect(sut.time == 0.0)
        #expect(sut.brewTimeString.isEmpty)
    }

    // MARK: - Formatting

    @Test("Formats seconds under one minute")
    func formatted_underOneMinute() {
        let sut = BrewTimerTextField.ViewModel()
        #expect(sut.formatted(0.0) == "0:00.0")
        #expect(sut.formatted(25.0) == "0:25.0")
        #expect(sut.formatted(59.9) == "0:59.9")
    }

    @Test("Formats seconds over one minute")
    func formatted_overOneMinute() {
        let sut = BrewTimerTextField.ViewModel()
        #expect(sut.formatted(83.4) == "1:23.4")
        #expect(sut.formatted(120.0) == "2:00.0")
        #expect(sut.formatted(185.5) == "3:05.5")
    }

    // MARK: - Start

    @Test("Start sets isRunning to true")
    func start_setsIsRunningTrue() {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        #expect(sut.isRunning)
        sut.pause()
    }

    @Test("Start advances time after a tick")
    func start_advancesTimeAfterTick() async throws {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        #expect(sut.time > 0)
        #expect(!sut.brewTimeString.isEmpty)
        sut.pause()
    }

    // MARK: - Pause

    @Test("Pause stops the timer")
    func pause_stopsTimer() async throws {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.pause()
        #expect(!sut.isRunning)
    }

    @Test("Pause preserves elapsed time")
    func pause_preservesElapsedTime() async throws {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.pause()
        let capturedTime = sut.time
        try await Task.sleep(for: .milliseconds(300))
        #expect(sut.time == capturedTime)
    }

    @Test("Pause while not running has no effect")
    func pause_whenNotRunning_noEffect() {
        let sut = BrewTimerTextField.ViewModel()
        sut.pause()
        #expect(!sut.isRunning)
        #expect(sut.time == 0)
        #expect(sut.brewTimeString.isEmpty)
    }

    // MARK: - Resume

    @Test("Start after pause resumes from paused time")
    func start_afterPause_resumesFromPausedTime() async throws {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.pause()
        let pausedTime = sut.time
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        #expect(sut.time > pausedTime)
        sut.pause()
    }

    // MARK: - Reset

    @Test("Reset clears all state")
    func reset_clearsAllState() async throws {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.reset()
        #expect(!sut.isRunning)
        #expect(sut.time == 0)
        #expect(sut.brewTimeString.isEmpty)
    }

    @Test("Reset while running stops and clears")
    func reset_whileRunning_stopsAndClears() async throws {
        let sut = BrewTimerTextField.ViewModel()
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        #expect(sut.isRunning)
        sut.reset()
        #expect(!sut.isRunning)
        #expect(sut.time == 0)
        #expect(sut.brewTimeString.isEmpty)
    }
}
