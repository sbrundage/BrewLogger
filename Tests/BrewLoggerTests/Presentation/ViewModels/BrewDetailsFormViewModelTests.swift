//
//  BrewDetailsFormViewModelTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 7/21/26.
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerData
import BrewLoggerDomain
import Testing

@Suite("BrewDetailsFormView.ViewModel")
@MainActor
struct BrewDetailsFormViewModelTests {

    private func brew(
        rating: Double? = 4,
        brewTemp: Int? = 195,
        notes: String? = nil,
        coffee: Coffee = .preview
    ) -> Brew {
        Brew(
            id: "brew-1",
            date: Date(timeIntervalSince1970: 1_000_000),
            coffee: coffee,
            grindSize: 3.5,
            dose: 18,
            yield: 36,
            brewTime: 28,
            method: .pourOver,
            brewTemp: brewTemp,
            rating: rating,
            notes: notes
        )
    }

    private func sut(_ brew: Brew) -> BrewDetailsFormView.ViewModel {
        BrewDetailsFormView.ViewModel(brew: brew, repository: StubBrewRepository())
    }

    // MARK: - Brew info rows

    @Test("Brew info includes rating and temp when present")
    func testBrewInfoRows_whenRatingAndTempPresent_shouldIncludeAllRows() {
        let rows = sut(brew()).brewInfoRows
        #expect(rows.map(\.label) == ["Grind Size", "Time", "Yield", "Method", "Rating", "Temp"])
        #expect(rows.map(\.value) == ["3.5", "28s", "36.0g", "Pour Over", "4.0 ★", "195°F"])
    }

    @Test("Brew info omits rating and temp when nil")
    func testBrewInfoRows_whenRatingAndTempNil_shouldOmitThoseRows() {
        let rows = sut(brew(rating: nil, brewTemp: nil)).brewInfoRows
        #expect(rows.map(\.label) == ["Grind Size", "Time", "Yield", "Method"])
    }

    // MARK: - Roast info rows

    @Test("Roast info is empty when the coffee has no roast info")
    func testRoastInfoRows_whenNoRoastInfo_shouldReturnEmpty() {
        let coffee = Coffee(id: "c", name: "X", originInfo: nil, roastInfo: nil, process: nil)
        #expect(sut(brew(coffee: coffee)).roastInfoRows.isEmpty)
    }

    @Test("Roast info includes only the present fields")
    func testRoastInfoRows_withPartialRoastInfo_shouldIncludeOnlyPresent() {
        let coffee = Coffee(
            id: "c", name: "X", originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: nil, roastLevel: nil),
            process: nil
        )
        let rows = sut(brew(coffee: coffee)).roastInfoRows
        #expect(rows.map(\.label) == ["Roaster"])
        #expect(rows.first?.value == "KOS")
    }

    // MARK: - Notes

    @Test("Notes is nil when the brew has none")
    func testNotes_whenNil_shouldReturnNil() {
        #expect(sut(brew(notes: nil)).notes == nil)
    }

    @Test("Notes is nil when the brew notes are empty")
    func testNotes_whenEmpty_shouldReturnNil() {
        #expect(sut(brew(notes: "")).notes == nil)
    }

    @Test("Notes returns the text when present")
    func testNotes_whenPresent_shouldReturnText() {
        #expect(sut(brew(notes: "clean")).notes == "clean")
    }

    // MARK: - Append note

    @Test("Appending with no existing notes sets the note")
    func testAppendNote_whenNoExistingNotes_shouldSetNote() {
        let vm = sut(brew(notes: nil))
        vm.appendNote("8 min post-brew: bright")
        #expect(vm.brew.notes == "8 min post-brew: bright")
    }

    @Test("Appending joins onto existing notes with a blank line")
    func testAppendNote_withExistingNotes_shouldJoinWithBlankLine() {
        let vm = sut(brew(notes: "0 min: sweet"))
        vm.appendNote("8 min: bright")
        #expect(vm.brew.notes == "0 min: sweet\n\n8 min: bright")
    }

    @Test("Appending blank text leaves notes unchanged")
    func testAppendNote_whenBlank_shouldNotChangeNotes() {
        let vm = sut(brew(notes: "sweet"))
        vm.appendNote("   ")
        #expect(vm.brew.notes == "sweet")
    }

    // MARK: - Passthrough

    @Test("Title and brew date pass through from the brew")
    func testTitleAndBrewDate_shouldMatchBrew() {
        let b = brew()
        let vm = sut(b)
        #expect(vm.title == b.coffee.name)
        #expect(vm.brewDate == b.date)
    }
}
