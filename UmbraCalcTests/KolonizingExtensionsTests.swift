//
//  KolonizingExtensionsTests.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-17.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import XCTest

@testable import UmbraCalc

class KolonizingExtensionsTests: XCTestCase {

    private struct NomOMatic: ResourceConverting {
        var inputResources: [String: Double] {
            return [
                "Mulch": 0.00005,
                "ElectricCharge": 3.0
            ] * Double(activeResourceConvertingCount)
        }
        var outputResources: [String: Double] {
            return [ "Supplies": 0.000025 ] * Double(activeResourceConvertingCount)
        }
        let activeResourceConvertingCount: Int
        init(count: Int = 1) {
            activeResourceConvertingCount = count
        }
    }

    private struct Nuke: ResourceConverting {
        let inputResources = [
            "EnrichedUranium": 0.000003
        ]
        let outputResources = [
            "DepletedUranium": 0.000002,
            "XenonGas": 0.000001,
            "ElectricCharge": 775
        ]
        let activeResourceConvertingCount = 1
    }

    private struct Crew: Crewing {
        let inputResources = [
                "Supplies": 0.00005,
                "ElectricCharge": 0.01
        ]
        let outputResources = [
            "Mulch": 0.00005
        ]
        let activeResourceConvertingCount = 1
        let career: String? = nil
        let name: String? = nil
        let starCount: Int16 = 0
        let crewable: Crewable? = nil
    }

    func testKerbinOrbitalStation1aNomOMatic() {
        struct Station: KolonizingCollectionType {
            let name: String? = nil
            let kolonizingCollection = AnyForwardCollection([Kolonizing]())
            let resourceConvertingCollection = AnyForwardCollection([NomOMatic(count: 3), Nuke()] as [ResourceConverting])
            let crewingCollection = AnyForwardCollection([Crew(), Crew(), Crew()] as [Crewing])
        }

        let output = Station().netResourceConversion
        print("output:", output * secondsPerDay)

        let mulch = output["Mulch"]
        XCTAssertNotNil(mulch)
        if mulch != nil {
            XCTAssertEqualWithAccuracy(mulch! * secondsPerDay, 3.24, accuracy: 0.005)
        }

        let supplies = output["Supplies"]
        XCTAssertNotNil(supplies)
        if supplies != nil {
            XCTAssertEqualWithAccuracy(supplies! * secondsPerDay, -1.62, accuracy: 0.005)
        }

        let electricCharge = output["ElectricCharge"]
        XCTAssertNotNil(electricCharge)
        if electricCharge != nil {
            XCTAssertEqualWithAccuracy(electricCharge!, 775 - 9.03, accuracy: 0.005)
        }
    }

}
