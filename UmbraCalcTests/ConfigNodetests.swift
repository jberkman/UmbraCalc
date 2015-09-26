//
//  ConfigNodeTests.swift
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

import Foundation
import XCTest

private let crewCapacityString = "CrewCapacity"
private let efficiencyPartString = "efficencyPart"
private let keyString = "key"
private let livingSpaceString = "livingSpace"
private let moduleString = "MODULE"
private let nameString = "name"
private let nodeString = "node"
private let partString = "PART"
private let titleString = "title"
private let valueString = "value"
private let workSpaceString = "workSpace"

private let partsExtension = "cfg"
private let partsSubdirectory = "Parts"

private let habRingName = "OKS_HabRing"
private let habRingTitle = "OKS Habitation Ring"
private let habRingCrewCapacity = "10"
private let habRingWorkSpace = "0"
private let habRingLivingSpace = "10"

private let drillFileName = "MKS_Drill_01"
private let drillName = "MKS_DRILL_01"
private let drillTitle = "MEU-500 Drill [MetallicOre/Substrate/Uraninite]"

private let MKSModuleName = "MKSModule"

@testable import UmbraCalc

class ConfigNodeTests: XCTestCase {

    static let simpleHabString = "\(partString){" +
        "\(nameString)=\(habRingName)\n" +
        "\(titleString)=\(habRingTitle)\n" +
        "\(crewCapacityString)=\(habRingCrewCapacity)\n" +
        "\(moduleString){" +
        "\(nameString)=\(MKSModuleName)\n" +
        "\(workSpaceString)=\(habRingWorkSpace)\n" +
        "\(livingSpaceString)=\(habRingLivingSpace)\n" +
    "}}"

    func configNodeWithString(string: String) -> [NSObject: AnyObject] {
        return ConfigNode.configNodeWithData(string.dataUsingEncoding(NSUTF8StringEncoding)!)
    }

    func testEmptyNode() {
        let node = configNodeWithString("\(nodeString){}")

        XCTAssertEqual(node.count, 1)
        XCTAssert(node[nodeString] is [NSObject: AnyObject])

        guard let subNode = node[nodeString] as? [NSObject: AnyObject] else { return }
        XCTAssertEqual(subNode.count, 0)
    }

    func testSimpleNode() {
        let node = configNodeWithString("\(nodeString){\(keyString)=\(valueString)}")

        XCTAssertEqual(node.count, 1)
        XCTAssert(node[nodeString] is [NSObject: AnyObject])

        guard let subNode = node[nodeString] as? [NSObject: AnyObject] else { return }
        XCTAssertEqual(subNode.count, 1)
        XCTAssert(subNode[keyString] is String)

        guard let value = subNode[keyString] as? String else { return }
        XCTAssertEqual(value, valueString)
    }

    func testAccumulatedValues() {
        let node = configNodeWithString("\(nodeString){\(keyString)=\(valueString)1\n\(keyString)=\(valueString)2}")

        XCTAssertEqual(node.count, 1)
        XCTAssert(node[nodeString] is [NSObject: AnyObject])

        guard let subNode = node[nodeString] as? [NSObject: AnyObject] else { return }

        XCTAssertEqual(subNode.count, 1)
        XCTAssert(subNode[keyString] is [String])

        guard let values = subNode[keyString] as? [String] else { return }
        XCTAssertEqual(values, ["\(valueString)1", "\(valueString)2"])
    }

    func testAccumulatedNodes() {
        let node = configNodeWithString("\(nodeString){\(nodeString){}\(nodeString){}}")

        XCTAssertEqual(node.count, 1)
        XCTAssert(node[nodeString] is [NSObject: AnyObject])

        guard let subNode = node[nodeString] as? [NSObject: AnyObject] else { return }
        XCTAssertEqual(subNode.count, 1)
        XCTAssert(subNode[nodeString] is [[NSObject: AnyObject]])

        guard let nodes = subNode[nodeString] as? [[NSObject: AnyObject]] else { return }
        XCTAssertEqual(nodes.count, 2)
        XCTAssertEqual(nodes[0].count, 0)
        XCTAssertEqual(nodes[1].count, 0)
    }

    func testSimpleHab() {
        let node = ConfigNode.configNodeWithData(ConfigNodeTests.simpleHabString.dataUsingEncoding(NSUTF8StringEncoding)!)

        XCTAssertEqual(node.count, 1)
        XCTAssert(node[partString] is [NSObject: AnyObject])

        guard let part = node[partString] as? [NSObject: AnyObject] else { return }
        XCTAssertEqual(part[nameString] as? String, habRingName)
        XCTAssertEqual(part[titleString] as? String, habRingTitle)
        XCTAssertEqual(part[crewCapacityString] as? String, habRingCrewCapacity)
        XCTAssert(part[moduleString] is [NSObject: AnyObject])

        guard let module = part[moduleString] as? [NSObject: AnyObject] else { return }
        XCTAssertEqual(module[nameString] as? String, MKSModuleName)
        XCTAssertEqual(module[workSpaceString] as? String, habRingWorkSpace)
        XCTAssertEqual(module[livingSpaceString] as? String, habRingLivingSpace)
        XCTAssertEqual(module[efficiencyPartString] as? String, nil)
    }

    func testMKSDrill01() {
        let URL: NSURL! = NSBundle.mainBundle().URLForResource(drillFileName, withExtension: partsExtension, subdirectory: partsSubdirectory)
        XCTAssertNotNil(URL)

        guard URL != nil else { return }
        let data: NSData! = NSData(contentsOfURL: URL)
        XCTAssertNotNil(data)

        guard data != nil else { return }
        let node = ConfigNode.configNodeWithData(data)
        XCTAssertEqual(node.count, 1)
        XCTAssert(node[partString] is [NSObject: AnyObject])

        guard let part = node[partString] as? [NSObject: AnyObject] else { return }
        XCTAssertEqual(part[nameString] as? String, drillName)
        XCTAssertEqual(part[titleString] as? String, drillTitle)
        XCTAssert(part[moduleString] is [[NSObject: AnyObject]])

        guard let modules = part[moduleString] as? [[NSObject: AnyObject]] else { return }
        XCTAssertEqual(modules.count, 5)
    }

}
