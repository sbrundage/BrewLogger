//
//  CoffeeModelMappingTests.swift
//  BrewLogger
//
//  Created by Stephen Brundage on 4/6/26.
//

@testable import BrewLoggerData

import Foundation
import BrewLoggerDomain
import CoreLogger
import Testing

@Suite("CoffeeModel mapping")
@MainActor
struct CoffeeModelMappingTests {
    let context = PersistenceController.previewBrew.container.viewContext

    @Test("toDomain returns nil when id is missing")
    func testToDomain_whenIdIsMissing_shouldReturnNil() {
        let sut = CoffeeModel(context: context)
        
        sut.name = "Rodrigo Sanchez"
        
        #expect(sut.toDomain() == nil)
    }

    @Test("toDomain returns nil when name is missing")
    func testToDomain_whenNameIsMissing_shouldReturnNil() {
        let sut = CoffeeModel(context: context)
        
        sut.id = UUID().uuidString
        
        #expect(sut.toDomain() == nil)
    }

    @Test("toDomain maps id, name, and roaster correctly")
    func testToDomain_withRequiredFields_shouldMapCorrectly() {
        // Arrange
        let sut = CoffeeModel(context: context)
        sut.id = "test-id"
        sut.name = "Rodrigo Sanchez"
        sut.roaster = "KOS"

        // Act
        let result = sut.toDomain()

        // Assert
        #expect(result?.id == "test-id")
        #expect(result?.name == "Rodrigo Sanchez")
        #expect(result?.roastInfo?.roaster == "KOS")
    }

    @Test("origin coordinate round-trips through update(from:) and toDomain()")
    func testOriginCoordinate_whenSetAndMappedBack_shouldRoundTrip() {
        // Arrange
        let coffee = Coffee(
            id: "c1",
            name: "Rodrigo Sanchez",
            originInfo: .init(location: "Huila, Colombia", altitude: 1730, latitude: 2.5359, longitude: -75.5277, canonicalName: "Huila, Colombia"),
            roastInfo: nil,
            process: nil,
            variety: nil,
            finishedAt: nil
        )
        let sut = CoffeeModel(context: context)

        // Act
        sut.update(from: coffee)
        let result = sut.toDomain()

        // Assert
        #expect(result?.originInfo?.latitude == 2.5359)
        #expect(result?.originInfo?.longitude == -75.5277)
        #expect(result?.originInfo?.canonicalName == "Huila, Colombia")
    }

    @Test("update(from:) sets id, name, and roaster from domain model")
    func testUpdateFrom_withCoffeeModel_shouldSetAllFields() {
        // Arrange
        let coffee = Coffee(id: "abc", name: "El Puente",
            originInfo: nil,
            roastInfo: .init(roaster: "KOS", date: nil, roastLevel: nil),
            process: nil, variety: nil, finishedAt: nil)
        let sut = CoffeeModel(context: context)

        // Act
        sut.update(from: coffee)

        // Assert
        #expect(sut.id == "abc")
        #expect(sut.name == "El Puente")
        #expect(sut.roaster == "KOS")
    }

    @Test("finishedAt round-trips through update(from:) and toDomain()")
    func testFinishedAt_whenSetAndMappedBack_shouldRoundTrip() {
        // Arrange
        let finished = Date(timeIntervalSince1970: 800_000)
        let coffee = Coffee(id: "c1", name: "X", originInfo: nil, roastInfo: nil, process: nil, variety: nil, finishedAt: finished)
        let sut = CoffeeModel(context: context)

        // Act
        sut.update(from: coffee)
        let result = sut.toDomain()

        // Assert
        #expect(sut.finishedAt == finished)
        #expect(result?.finishedAt == finished)
        #expect(result?.isFinished == true)
    }

    @Test("A coffee with no finishedAt is active")
    func testToDomain_whenFinishedAtNotSet_shouldBeActive() {
        let sut = CoffeeModel(context: context)
        sut.id = "c"
        sut.name = "X"
        #expect(sut.toDomain()?.isFinished == false)
    }
}
