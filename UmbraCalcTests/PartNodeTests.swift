//
//  PartNodeTests.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-25.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import XCTest

@testable import UmbraCalc

class PartNodeTests: XCTestCase {

    func testSimpleHab() {
        let configNode = ConfigNode.configNodeWithData(ConfigNodeTests.simpleHabString.dataUsingEncoding(NSUTF8StringEncoding)!)
        let partNode: PartNode! = PartNode(configNode: configNode)

        XCTAssertNotNil(partNode)
        guard partNode != nil else { return }

        XCTAssertEqual(partNode.name, "OKS_HabRing")
        XCTAssertEqual(partNode.title, "OKS Habitation Ring")
        XCTAssertEqual(partNode.crewCapacity, 10)
        XCTAssertEqual(partNode.workspaceCount, 0)
        XCTAssertEqual(partNode.livingSpaceCount, 10)
        XCTAssertEqual(partNode.efficiencyParts.count, 0)
    }

    func testHab() {
        let partNode: PartNode! = PartNode(named: "OKS_HabRing")

        XCTAssertNotNil(partNode)
        guard partNode != nil else { return }

        XCTAssertEqual(partNode.name, "OKS_HabRing")
        XCTAssertEqual(partNode.title, "OKS Habitation Ring")
        XCTAssertEqual(partNode.crewCapacity, 10)
        XCTAssertEqual(partNode.workspaceCount, 0)
        XCTAssertEqual(partNode.livingSpaceCount, 10)
        XCTAssert(partNode.efficiencyParts.isEmpty)
    }

    func testBundledPartNames() {
        XCTAssertEqual(NSBundle.mainBundle().partNodes.count, 67)
    }

}
