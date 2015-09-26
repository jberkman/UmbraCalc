//
//  CrewTests.swift
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

private let careers = [ "", Crew.engineerTitle, Crew.scientistTitle, Crew.pilotTitle, "banana salesman" ]
private let names = [ "Jebediah", "Bill", "Bob", "Valentina" ]

extension CoreDataStackTestCase {

    func insertPilotWithStarCount(starCount: Int) -> Crew {
        return insertCrew()!.withCareer(Crew.pilotTitle).withStarCount(starCount)
    }

    func insertEngineerWithStarCount(starCount: Int) -> Crew {
        return insertCrew()!.withCareer(Crew.engineerTitle).withStarCount(starCount)
    }

    func insertScientistWithStarCount(starCount: Int) -> Crew {
        return insertCrew()!.withCareer(Crew.scientistTitle).withStarCount(starCount)
    }

    func insertTouristWithStarCount(starCount: Int) -> Crew {
        return insertCrew()!.withCareer("Tourist").withStarCount(starCount)
    }

}

class CrewTests: CoreDataStackTestCase {

    func testInsertCrewWithCareer() {
        careers.forEach {
            XCTAssertEqual(insertCrew()!.withCareer($0).career, $0)
        }
    }

    func testWithCareer() {
        let crew = insertCrew()!
        careers.forEach {
            XCTAssertEqual(crew.withCareer($0).career, $0)
        }
    }

    func testWithName() {
        let crew = insertCrew()!
        XCTAssertNil(crew.name)
        names.forEach {
            XCTAssertEqual(crew.withName($0).name, $0)
        }
    }

    func testWithPart() {
        let crew = insertCrew()!
        XCTAssertNil(crew.part)
        [ insertHabitationModulePart(), insertHabRingPart(), insertCommandPodPart() ].forEach {
            XCTAssertEqual(crew.withPart($0).part, $0)
        }
    }

    func testWithStarCount() {
        let crew = insertCrew()!
        XCTAssertEqual(crew.starCount, 0)
        (0 ... 5).forEach {
            XCTAssertEqual(crew.withStarCount($0).starCount, Int16($0))
        }
    }

}
