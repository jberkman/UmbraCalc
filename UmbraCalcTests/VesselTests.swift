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

class VesselTests: CoreDataStackTestCase {

    func testEmptyVessel() {
        let vessel = insertVessel()!
        XCTAssertEqual(vessel.workspaceCount, 0)
        XCTAssertEqual(vessel.crewCapacity, 0)
        XCTAssertEqual(vessel.livingSpaceCount, 0)
        XCTAssertEqual(vessel.crewCount, 0)
        XCTAssertEqual(vessel.crewCareerFactor, 0)
        XCTAssertEqual(vessel.happinessCrewCapacity, 0)
        XCTAssertEqual(vessel.happinessCrewCount, 0)
        XCTAssertEqual(vessel.happinessLivingSpaceCount, 0)
        XCTAssertEqual(vessel.efficiencyWorkspaceCount, 0)
        XCTAssertEqual(vessel.efficiencyParts.count, 0)
        XCTAssertEqual(vessel.crewHappiness, 0)
    }

    func testHabRing() {
        let accuracy = 0.005

        let vessel = insertVessel()!
        let habRing = insertHabRingPart().withVessel(vessel)
        XCTAssertEqual(vessel.workspaceCount, 0)
        XCTAssertEqual(vessel.crewCapacity, 10)
        XCTAssertEqual(vessel.livingSpaceCount, 10)
        XCTAssertEqual(vessel.crewCount, 0)
        XCTAssertEqual(vessel.crewCareerFactor, 0)
        XCTAssertEqual(vessel.happinessCrewCapacity, 10)
        XCTAssertEqual(vessel.happinessCrewCount, 0)
        XCTAssertEqual(vessel.happinessLivingSpaceCount, 10)
        XCTAssertEqual(vessel.efficiencyWorkspaceCount, 0)
        XCTAssertEqual(vessel.efficiencyParts.count, 1)
        XCTAssertEqual(vessel.crewHappiness, 0)

        habRing.count = 2
        XCTAssertEqual(vessel.workspaceCount, 0)
        XCTAssertEqual(vessel.crewCapacity, 20)
        XCTAssertEqual(vessel.livingSpaceCount, 20)
        XCTAssertEqual(vessel.crewCount, 0)
        XCTAssertEqual(vessel.crewCareerFactor, 0)
        XCTAssertEqual(vessel.happinessCrewCapacity, 20)
        XCTAssertEqual(vessel.happinessCrewCount, 0)
        XCTAssertEqual(vessel.happinessLivingSpaceCount, 20)
        XCTAssertEqual(vessel.efficiencyWorkspaceCount, 0)
        XCTAssertEqual(vessel.crewHappiness, 0)

        habRing.withCount(1).withCrew([insertPilotWithStarCount(4)])
        XCTAssertEqual(vessel.crewCount, 1)
        XCTAssertEqual(vessel.crewCareerFactor, 1)
        XCTAssertEqual(vessel.happinessCrewCount, 1)
        XCTAssertEqualWithAccuracy(vessel.crewHappiness, 1.5 * 0.2, accuracy: accuracy)
        // XCTAssertEqualWithAccuracy(vessel.crewEfficiency, 0.825, accuracy: accuracy)
    }

    func testCrewHappiness() {
        let accuracy = 0.005

        let vessel = insertVessel()!
        let habRing = insertHabRingPart().withVessel(vessel).withCrew((0 ..< 4).map { _ in self.insertCrew()! })
        XCTAssertEqualWithAccuracy(vessel.crewHappiness, 1.5 * 0.8, accuracy: accuracy)

        (0 ..< 4).forEach { _ in self.insertCrew()!.withPart(habRing) }
        XCTAssertEqualWithAccuracy(vessel.crewHappiness, 1.25 * 1.1, accuracy: accuracy)
        habRing.vessel = nil

        insertHabitationModulePart().withVessel(vessel).withCrew((0 ..< 7).map { _ in self.insertCrew()! })
        XCTAssertEqualWithAccuracy(vessel.crewHappiness, 0.63 /* ??? */, accuracy: accuracy)
    }
}

extension PartTests {

    func testSimplePartsEfficiency() {
        let accuracy = 0.005
        let vessel = insertVessel()!

        let kerbitat = insertKerbitatPart().withVessel(vessel)
        XCTAssertEqualWithAccuracy(kerbitat.partsEfficiency, 0, accuracy: accuracy)

        let habitationModule = insertHabitationModulePart().withVessel(vessel)
        XCTAssertEqualWithAccuracy(kerbitat.partsEfficiency, 2, accuracy: accuracy)

        habitationModule.count = 2
        XCTAssertEqualWithAccuracy(kerbitat.partsEfficiency, 4, accuracy: accuracy)

        habitationModule.count = 100
        XCTAssertEqualWithAccuracy(kerbitat.partsEfficiency, 200, accuracy: accuracy)
    }

}
