//
//  PartTests.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-23.
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

class PartTests: CoreDataStackTestCase {

    func testInitWithConfigNode() {
        let part = insertHabitationModulePart()

        XCTAssertEqual(part.partName, "Habitation Module")
        XCTAssertEqual(part.name, "Habitation Module")
        XCTAssertEqual(part.title, "Habitation Module")
        XCTAssertEqual(part.crewCapacity, 4)
        XCTAssertEqual(part.livingSpaceCount, 4)
        XCTAssertEqual(part.workspaceCount, 0)
        XCTAssertEqual(part.count, 1)
        XCTAssertEqual(part.efficiencyParts.count, 0)
    }
    
    func testCrewCareerFactor() {
        let accuracy = 0.0001

        XCTAssertEqualWithAccuracy(insertHabitationModulePart().withCrew([insertEngineerWithStarCount(5)]).crewCareerFactor, 3.75, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertHabitationModulePart().withCrew([insertScientistWithStarCount(3), insertPilotWithStarCount(4)]).crewCareerFactor, 2.5, accuracy: accuracy)
    }

}

extension CrewTests {

    // Level 0 Pilot:       0.05
    // Level 0 Engineer:    0.15
    // Level 1 Pilot:       0.25
    // Level 1 Engineer:    0.75
    // Level 2 Pilot:       0.50
    // Level 2 Engineer:    1.50
    // Level 3 Scientist:   1.50
    // Level 4 Pilot:       1.0
    // Level 5 Pilot:       1.25
    // Level 5 engineer:    3.75
    func testCareerFactor() {
        let accuracy = 0.005
        XCTAssertEqualWithAccuracy(insertPilotWithStarCount(0).withPart(insertKerbitatPart()).careerFactor, 0.05, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertEngineerWithStarCount(0).withPart(insertKerbitatPart()).careerFactor, 0.15, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertPilotWithStarCount(1).withPart(insertKerbitatPart()).careerFactor, 0.25, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertEngineerWithStarCount(1).withPart(insertKerbitatPart()).careerFactor, 0.75, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertPilotWithStarCount(2).withPart(insertKerbitatPart()).careerFactor, 0.50, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertEngineerWithStarCount(2).withPart(insertKerbitatPart()).careerFactor, 1.50, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertScientistWithStarCount(3).withPart(insertKerbitatPart()).careerFactor, 1.50, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertPilotWithStarCount(4).withPart(insertKerbitatPart()).careerFactor, 1.0, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertPilotWithStarCount(5).withPart(insertKerbitatPart()).careerFactor, 1.25, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertEngineerWithStarCount(5).withPart(insertKerbitatPart()).careerFactor, 3.75, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertTouristWithStarCount(0).withPart(insertKerbitatPart()).careerFactor, 0.05, accuracy: accuracy)
        XCTAssertEqualWithAccuracy(insertTouristWithStarCount(5).withPart(insertKerbitatPart()).careerFactor, 1.25, accuracy: accuracy)
    }

}