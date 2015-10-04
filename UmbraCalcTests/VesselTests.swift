//
//  VesselTests.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import CoreData
import XCTest

@testable import UmbraCalc

extension CoreDataStackTestCase {

    func vessel() -> Vessel {
        return try! Vessel(insertIntoManagedObjectContext: managedObjectContext!)
    }

}

class VesselTests: CoreDataStackTestCase {

    func testEmptyVessel() {
        let subject = vessel()
        XCTAssertEqual(subject.workspaceCount, 0)
        XCTAssertEqual(subject.crewCapacity, 0)
        XCTAssertEqual(subject.livingSpaceCount, 0)
        XCTAssertEqual(subject.crewCount, 0)
        XCTAssertEqual(subject.crewCareerFactor, 0)
        XCTAssertEqual(subject.happinessCrewCapacity, 0)
        XCTAssertEqual(subject.happinessCrewCount, 0)
        XCTAssertEqual(subject.happinessLivingSpaceCount, 0)
        XCTAssertEqual(subject.efficiencyWorkspaceCount, 0)
        XCTAssertEqual(subject.efficiencyParts.count, 0)
        XCTAssertEqual(subject.crewHappiness, 0)
    }

    func testHabRing() {
        let accuracy = 0.005

        let subject = vessel()
        let hab = habRing().withVessel(subject)
        XCTAssertEqual(subject.workspaceCount, 0)
        XCTAssertEqual(subject.crewCapacity, 10)
        XCTAssertEqual(subject.livingSpaceCount, 10)
        XCTAssertEqual(subject.crewCount, 0)
        XCTAssertEqual(subject.crewCareerFactor, 0)
        XCTAssertEqual(subject.happinessCrewCapacity, 10)
        XCTAssertEqual(subject.happinessCrewCount, 0)
        XCTAssertEqual(subject.happinessLivingSpaceCount, 10)
        XCTAssertEqual(subject.efficiencyWorkspaceCount, 0)
        XCTAssertEqual(subject.efficiencyParts.count, 1)
        XCTAssertEqual(subject.crewHappiness, 0)

        hab.count = 2
        XCTAssertEqual(subject.workspaceCount, 0)
        XCTAssertEqual(subject.crewCapacity, 20)
        XCTAssertEqual(subject.livingSpaceCount, 20)
        XCTAssertEqual(subject.crewCount, 0)
        XCTAssertEqual(subject.crewCareerFactor, 0)
        XCTAssertEqual(subject.happinessCrewCapacity, 20)
        XCTAssertEqual(subject.happinessCrewCount, 0)
        XCTAssertEqual(subject.happinessLivingSpaceCount, 20)
        XCTAssertEqual(subject.efficiencyWorkspaceCount, 0)
        XCTAssertEqual(subject.crewHappiness, 0)

        hab.withCount(1).withCrew([pilot().withStarCount(4)])
        XCTAssertEqual(subject.crewCount, 1)
        XCTAssertEqual(subject.crewCareerFactor, 1)
        XCTAssertEqual(subject.happinessCrewCount, 1)
        XCTAssertEqualWithAccuracy(subject.crewHappiness, 1.5 * 0.2, accuracy: accuracy)
        // XCTAssertEqualWithAccuracy(subject.crewEfficiency, 0.825, accuracy: accuracy)
    }

    func testCrewHappiness() {
        let accuracy = 0.005

        let subject = vessel()
        let hab = habRing().withVessel(subject).withCrew((0 ..< 4).map { _ in self.crew() })
        XCTAssertEqualWithAccuracy(subject.crewHappiness, 1.5 * 0.8, accuracy: accuracy)

        (0 ..< 4).forEach { _ in self.crew().withPart(hab) }
        XCTAssertEqualWithAccuracy(subject.crewHappiness, 1.25 * 1.1, accuracy: accuracy)
        hab.vessel = nil

        habitationModule().withVessel(subject).withCrew((0 ..< 7).map { _ in self.crew() })
        XCTAssertEqualWithAccuracy(subject.crewHappiness, 0.63 /* ??? */, accuracy: accuracy)
    }
}

extension PartTests {

    func testSimplePartsEfficiency() {
        let accuracy = 0.005
        let subject = vessel()

        let kerb = kerbitat().withVessel(subject)
        XCTAssertEqualWithAccuracy(kerb.partsEfficiency, 0, accuracy: accuracy)

        let hab = habitationModule().withVessel(subject)
        XCTAssertEqualWithAccuracy(kerb.partsEfficiency, 2, accuracy: accuracy)

        hab.count = 2
        XCTAssertEqualWithAccuracy(kerb.partsEfficiency, 4, accuracy: accuracy)

        hab.count = 100
        XCTAssertEqualWithAccuracy(kerb.partsEfficiency, 200, accuracy: accuracy)
    }

}
