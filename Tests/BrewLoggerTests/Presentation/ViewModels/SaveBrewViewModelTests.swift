//
//  SaveBrewViewModelTests.swift
//  BrewLogger
//

@testable import BrewLoggerPresentation

import Foundation
import BrewLoggerData
import BrewLoggerDomain
import Testing

@Suite("SaveBrewViewModel")
@MainActor
struct SaveBrewViewModelTests {

    // MARK: - Prefill roast date

    @Test("Selecting a coffee prefills the roast date from its current bag")
    func testPrefillRoastDateFromCoffee_shouldCopyCoffeeRoastDate() {
        // Arrange
        let roasted = Date(timeIntervalSince1970: 500_000)
        let (sut, _) = makeSUT()
        sut.brew.coffee = coffee(roastDate: roasted)

        // Act
        sut.prefillRoastDateFromCoffee()

        // Assert
        #expect(sut.brew.roastDate == roasted)
    }

    @Test("Editing an existing brew does not prefill the roast date")
    func testPrefillRoastDateFromCoffee_whenEditing_shouldNotOverwrite() {
        // Arrange
        let snapshot = Date(timeIntervalSince1970: 111)
        let editBrew = brew(coffee: coffee(roastDate: Date(timeIntervalSince1970: 999)), roastDate: snapshot)
        let sut = SaveBrewViewModel(
            brewToEdit: editBrew,
            coffeeRepository: SpyCoffeeRepository(coffees: []),
            brewRepository: StubBrewRepository(brews: [editBrew])
        )

        // Act
        sut.prefillRoastDateFromCoffee()

        // Assert
        #expect(sut.brew.roastDate == snapshot)
    }

    // MARK: - New-bag write-back

    @Test("Saving a new brew with a changed roast date opens a new bag on the coffee")
    func testSaveBrew_whenRoastDateChanged_shouldUpdateCoffeeAndReopen() throws {
        // Arrange
        let oldDate = Date(timeIntervalSince1970: 0)
        let newDate = Date(timeIntervalSince1970: 500_000)
        let existing = Coffee(
            id: "c", name: "X", originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: oldDate, roastLevel: .light),
            process: nil, variety: nil, finishedAt: Date()
        )
        let (sut, spy) = makeSUT(coffees: [existing])
        fill(sut, coffee: existing, roastDate: newDate)

        // Act
        try sut.saveBrew()

        // Assert
        let updated = try #require(spy.updated.first)
        #expect(updated.roastInfo?.date == newDate)
        #expect(updated.roastInfo?.roaster == "KOS")   // stable fields preserved
        #expect(updated.isFinished == false)           // reactivated
    }

    @Test("Saving a new brew with an unchanged roast date leaves the coffee alone")
    func testSaveBrew_whenRoastDateUnchanged_shouldNotUpdateCoffee() throws {
        let date = Date(timeIntervalSince1970: 500_000)
        let existing = coffee(roastDate: date)
        let (sut, spy) = makeSUT(coffees: [existing])
        fill(sut, coffee: existing, roastDate: date)

        try sut.saveBrew()

        #expect(spy.updated.isEmpty)
    }

    @Test("Editing an existing brew never writes back to the coffee")
    func testSaveBrew_whenEditing_shouldNotUpdateCoffee() throws {
        let existing = coffee(roastDate: Date(timeIntervalSince1970: 0))
        let editBrew = brew(coffee: existing, roastDate: Date(timeIntervalSince1970: 999_999))
        let spy = SpyCoffeeRepository(coffees: [existing])
        let sut = SaveBrewViewModel(
            brewToEdit: editBrew,
            coffeeRepository: spy,
            brewRepository: StubBrewRepository(brews: [editBrew])
        )

        try sut.saveBrew()

        #expect(spy.updated.isEmpty)
    }
}

private extension SaveBrewViewModelTests {
    func makeSUT(coffees: [Coffee] = []) -> (SaveBrewViewModel, SpyCoffeeRepository) {
        let spy = SpyCoffeeRepository(coffees: coffees)
        let sut = SaveBrewViewModel(coffeeRepository: spy, brewRepository: StubBrewRepository(brews: []))
        return (sut, spy)
    }

    func fill(_ sut: SaveBrewViewModel, coffee: Coffee, roastDate: Date) {
        sut.brew.coffee = coffee
        sut.brew.method = .pourOver
        sut.brew.grindSize = "3.5"
        sut.brew.dose = "18"
        sut.brew.yield = "36"
        sut.brew.brewTime = "28"
        sut.brew.roastDate = roastDate
    }

    func coffee(roastDate: Date?) -> Coffee {
        Coffee(
            id: "c", name: "X", originInfo: nil,
            roastInfo: .init(roaster: nil, date: roastDate, roastLevel: nil),
            process: nil, variety: nil, finishedAt: nil
        )
    }

    func brew(coffee: Coffee, roastDate: Date?) -> Brew {
        Brew(
            id: "b1", date: Date(timeIntervalSince1970: 1_000_000), coffee: coffee,
            grindSize: 3.5, dose: 18, yield: 36, brewTime: 28, method: .pourOver,
            brewTemp: nil, roastDate: roastDate, tastingEntries: []
        )
    }
}

private final class SpyCoffeeRepository: CoffeeRepository {
    private(set) var updated: [Coffee] = []
    private var coffees: [Coffee]

    init(coffees: [Coffee]) { self.coffees = coffees }

    func log(_ coffee: Coffee) throws { coffees.append(coffee) }
    func fetch(coffeeId: String) throws -> Coffee? { coffees.first { $0.id == coffeeId } }
    func fetchAll() throws -> [Coffee] { coffees }
    func delete(id: String) throws { coffees.removeAll { $0.id == id } }
    func update(_ coffee: Coffee) throws {
        updated.append(coffee)
        if let i = coffees.firstIndex(where: { $0.id == coffee.id }) { coffees[i] = coffee }
    }
}
