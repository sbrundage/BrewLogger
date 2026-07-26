//
//  AddNoteViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/21/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerDomain
import Testing

@Suite("AddNoteSheet.ViewModel")
@MainActor
struct AddNoteViewModelTests {

    private let brewDate = Date(timeIntervalSince1970: 1_000_000)

    private func sut(minutesAfter: Double) -> AddNoteSheet.ViewModel {
        AddNoteSheet.ViewModel(
            brewDate: brewDate,
            openedAt: brewDate.addingTimeInterval(minutesAfter * 60)
        )
    }

    // MARK: - Time mark

    @Test("Time mark within the window shows minutes since brew")
    func testTimeMark_whenWithinWindow_shouldReturnMinutes() {
        #expect(sut(minutesAfter: 8).timeMark == "8 min post-brew")
    }

    @Test("Time mark at brew time is zero minutes")
    func testTimeMark_atBrewTime_shouldReturnZeroMinutes() {
        #expect(sut(minutesAfter: 0).timeMark == "0 min post-brew")
    }

    @Test("Time mark at the window boundary is included")
    func testTimeMark_atWindowBoundary_shouldReturnMinutes() {
        #expect(sut(minutesAfter: 30).timeMark == "30 min post-brew")
    }

    @Test("Time mark past the window is nil")
    func testTimeMark_pastWindow_shouldReturnNil() {
        #expect(sut(minutesAfter: 31).timeMark == nil)
    }

    @Test("Time mark is nil when opened before the brew date")
    func testTimeMark_whenOpenedBeforeBrew_shouldReturnNil() {
        #expect(sut(minutesAfter: -5).timeMark == nil)
    }

    // MARK: - Can save

    @Test("Empty note cannot be saved")
    func testCanSave_whenNoteEmpty_shouldReturnFalse() {
        #expect(!sut(minutesAfter: 0).canSave)
    }

    @Test("Whitespace-only note cannot be saved")
    func testCanSave_whenNoteWhitespace_shouldReturnFalse() {
        let vm = sut(minutesAfter: 0)
        vm.note = "   \n "
        #expect(!vm.canSave)
    }

    @Test("Note with text can be saved")
    func testCanSave_whenNoteHasText_shouldReturnTrue() {
        let vm = sut(minutesAfter: 0)
        vm.note = "bright"
        #expect(vm.canSave)
    }

    // MARK: - Make entry

    @Test("Made entry captures note, rating, and the open time")
    func testMakeEntry_withNoteAndRating_shouldBuildEntry() {
        // Arrange
        let vm = sut(minutesAfter: 8)
        vm.note = "bright and juicy"
        vm.rating = "4.5"

        // Act
        let entry = vm.makeEntry()

        // Assert
        #expect(entry.note == "bright and juicy")
        #expect(entry.rating == 4.5)
        #expect(entry.createdAt == brewDate.addingTimeInterval(8 * 60))
    }

    @Test("Made entry has a nil rating when the rating text is empty")
    func testMakeEntry_whenRatingEmpty_shouldHaveNilRating() {
        let vm = sut(minutesAfter: 0)
        vm.note = "sweet"

        #expect(vm.makeEntry().rating == nil)
    }
}
