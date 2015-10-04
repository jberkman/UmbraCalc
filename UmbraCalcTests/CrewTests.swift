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

    func crew() -> Crew {
        return try! Crew(insertIntoManagedObjectContext: managedObjectContext!)
    }

    func pilot() -> Crew {
        return crew().withCareer(Crew.pilotTitle)
    }

    func engineer() -> Crew {
        return crew().withCareer(Crew.engineerTitle)
    }

    func scientist() -> Crew {
        return crew().withCareer(Crew.scientistTitle)
    }

    func tourist() -> Crew {
        return crew().withCareer("Tourist")
    }

}

class CrewTests: CoreDataStackTestCase {

    func testCrewWithCareer() {
        careers.forEach {
            XCTAssertEqual(crew().withCareer($0).career, $0)
        }
    }

    func testWithCareer() {
        let subject = crew()
        careers.forEach {
            XCTAssertEqual(subject.withCareer($0).career, $0)
        }
    }

    func testWithName() {
        let subject = crew()
        XCTAssertNil(subject.name)
        names.forEach {
            XCTAssertEqual(subject.withName($0).name, $0)
        }
    }

    func testWithPart() {
        let subject = crew()
        XCTAssertNil(subject.part)
        [ habitationModule(), habRing(), commandPod() ].forEach {
            XCTAssertEqual(subject.withPart($0).part, $0)
        }
    }

    func testWithStarCount() {
        let subject = crew()
        XCTAssertEqual(subject.starCount, 0)
        (0 ... 5).forEach {
            XCTAssertEqual(subject.withStarCount($0).starCount, Int16($0))
        }
    }

}
