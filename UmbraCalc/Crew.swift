//
//  Crew.swift
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

import Apropos
import Balsa
import CoreData
import Foundation

class Crew: NamedEntity {

    @NSManaged var career: String?
    @NSManaged var starCount: Int16

    @NSManaged private var primitivePart: Part?

    dynamic var part: Part? {
        get {
            willAccessValueForKey("part")
            let ret = primitivePart
            didAccessValueForKey("part")
            return ret
        }
        set {
            willChangeValueForKey("part")
            primitivePart = newValue
            rootScope = newValue?.rootScope
            scopeGroup = newValue?.scopeGroup
            didChangeValueForKey("part")
        }
    }

    override var superscope: ScopedEntity? {
        return part
    }

    @warn_unused_result
    func withCareer(career: String) -> Self {
        return withValue(career, forKey: "career")
    }

    @warn_unused_result
    func withPart(part: Part?) -> Self {
        return withValue(part, forKey: "part")
    }

    @warn_unused_result
    func withStarCount(starCount: Int) -> Self {
        return withValue(starCount, forKey: "starCount")
    }

}

extension Crew: ResourceConverting {

    var inputResources: [String: Double] {
        return [
            "Supplies": 0.00005,
            "ElectricCharge": 0.01
        ]
    }

    var outputResources: [String: Double] {
        return ["Mulch": 0.00005]
    }

    var activeResourceConvertingCount: Int { return 1 }

}

extension Crew: Crewing {

    var crewable: Crewable? { return part }

}

extension Crew: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "Crew" }

}
