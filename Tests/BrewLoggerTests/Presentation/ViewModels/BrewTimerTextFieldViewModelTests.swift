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
    let sut = BrewTimerTextField.ViewModel()

    // MARK: - Initialization

    @Test("Default initialization")
    func testInit_withNoArguments_shouldHaveDefaultValues() {
        #expect(!sut.isRunning)
        #expect(sut.time == 0.0)
        #expect(sut.brewTimeString.isEmpty)
    }

    // MARK: - Formatting

    @Test("Formats seconds under one minute")
    func testFormatted_whenUnderOneMinute_shouldFormatAsMinutesSeconds() {
        #expect(sut.formatted(0.0) == "0:00.0")
        #expect(sut.formatted(25.0) == "0:25.0")
        #expect(sut.formatted(59.9) == "0:59.9")
    }

    @Test("Formats seconds over one minute")
    func testFormatted_whenOverOneMinute_shouldFormatAsMinutesSeconds() {
        #expect(sut.formatted(83.4) == "1:23.4")
        #expect(sut.formatted(120.0) == "2:00.0")
        #expect(sut.formatted(185.5) == "3:05.5")
    }

    // MARK: - Start

    @Test("Start sets isRunning to true")
    func testStart_whenStopped_shouldSetIsRunningTrue() {
        sut.start()
        
        #expect(sut.isRunning)
    }

    @Test("Start advances time after a tick")
    func testStart_afterTick_shouldAdvanceTime() async throws {
        sut.start()
        
        try await Task.sleep(for: .milliseconds(300))
        
        #expect(sut.time > 0)
        #expect(!sut.brewTimeString.isEmpty)
    }

    // MARK: - Pause

    @Test("Pause stops the timer")
    func testPause_whenRunning_shouldStopTimer() async throws {
        sut.start()
        
        try await Task.sleep(for: .milliseconds(300))
        
        sut.pause()
        
        #expect(!sut.isRunning)
    }

    @Test("Pause preserves elapsed time")
    func testPause_whenRunning_shouldPreserveElapsedTime() async throws {
        // Arrange
        sut.start()
        
        try await Task.sleep(for: .milliseconds(300))
        
        // Act
        sut.pause()
        
        let capturedTime = sut.time
        try await Task.sleep(for: .milliseconds(300))
        
        // Assert
        #expect(sut.time == capturedTime)
    }

    @Test("Pause while not running has no effect")
    func testPause_whenNotRunning_shouldHaveNoEffect() {
        sut.pause()
        
        #expect(!sut.isRunning)
        #expect(sut.time == 0)
        #expect(sut.brewTimeString.isEmpty)
    }

    // MARK: - Resume

    @Test("Start after pause resumes from paused time")
    func testStart_afterPause_shouldResumeFromPausedTime() async throws {
        // Arrange
        sut.start()
        try await Task.sleep(for: .milliseconds(300))
        sut.pause()
        let pausedTime = sut.time
        
        // Act
        sut.start()
        
        try await Task.sleep(for: .milliseconds(300))
        
        // Assert
        #expect(sut.time > pausedTime)
    }

    // MARK: - Reset

    @Test("Reset clears all state")
    func testReset_whenRunning_shouldClearAllState() async throws {
        sut.start()
        
        try await Task.sleep(for: .milliseconds(300))
        
        sut.reset()
        
        #expect(!sut.isRunning)
        #expect(sut.time == 0)
        #expect(sut.brewTimeString.isEmpty)
    }

    @Test("Reset while running stops and clears")
    func testReset_whileRunning_shouldStopAndClear() async throws {
        // Arrange
        sut.start()
        
        try await Task.sleep(for: .milliseconds(300))
        
        #expect(sut.isRunning)
        
        // Act
        sut.reset()
        
        // Assert
        #expect(!sut.isRunning)
        #expect(sut.time == 0)
        #expect(sut.brewTimeString.isEmpty)
    }

    // MARK: - Stopped at

    @Test("Pause records the stop timestamp")
    func testPause_whenRunning_shouldRecordStoppedAt() {
        sut.start()

        sut.pause()

        #expect(sut.stoppedAt != nil)
    }

    @Test("Pause while not running leaves the stop timestamp nil")
    func testPause_whenNotRunning_shouldLeaveStoppedAtNil() {
        sut.pause()

        #expect(sut.stoppedAt == nil)
    }

    @Test("Reset clears the stop timestamp")
    func testReset_whenStopped_shouldClearStoppedAt() {
        // Arrange
        sut.start()
        sut.pause()
        #expect(sut.stoppedAt != nil)

        // Act
        sut.reset()

        // Assert
        #expect(sut.stoppedAt == nil)
    }
}
