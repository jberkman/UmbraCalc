//
//  Vessel.swift
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

import Foundation
import CoreData

private let minEfficiency = 0.25
private let maxEfficiency = 2.5

class Vessel: NamedEntity {

    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

    func withParts<S: SequenceType where S.Generator.Element == Part>(parts: S) -> Self {
        return withValue(Set(parts), forKey: "parts")
    }

    private func partSum(transform: (Part) -> Int) -> Int {
        return (parts as? Set<Part>)?.map(transform).reduce(0, combine: +) ?? 0
    }

    private func partSum(transform: (Part) -> Double) -> Double {
        return (parts as? Set<Part>)?.map(transform).reduce(0.0, combine: +) ?? 0
    }

    var partCount: Int {
        return partSum { Int($0.count) }
    }

    var workspaceCount: Int {
        return partSum { $0.workspaceCount }
    }

    var crewCapacity: Int {
        return partSum { $0.crewCapacity }
    }

    var livingSpaceCount: Int {
        return partSum { $0.livingSpaceCount }
    }

    var crewCount: Int {
        return partSum { $0.crew?.count ?? 0 }
    }

    var crewCareerFactor: Double {
        return partSum { $0.crewCareerFactor }
    }

    var happinessCrewCapacity: Int {
        return crewCapacity
    }

    var happinessCrewCount: Int {
        return crewCount
    }

    var happinessLivingSpaceCount: Int {
        return livingSpaceCount
    }

    var efficiencyWorkspaceCount: Int {
        return workspaceCount
    }

    var efficiencyParts: Set<Part> {
        return parts as? Set<Part> ?? Set()
    }

    var crewHappiness: Double {
        let minHappinessFactor = 0.5
        let maxHappinessFactor = 1.5

        let crewCount = Double(happinessCrewCount)
        guard crewCount > 0 else { return 0 }
        let sadness = min(5, crewCount) / 5

        let livingSpaces = Double(happinessLivingSpaceCount) + Double(happinessCrewCapacity) / 10

        return sadness * max(minHappinessFactor, min(maxHappinessFactor, livingSpaces / crewCount))
    }

}

extension ManagingObjectContext {

    func insertVessel() -> Vessel? {
        guard let managedObjectContext = managedObjectContext,
            entity = NSEntityDescription.entityForName("Vessel", inManagedObjectContext: managedObjectContext) else { return nil  }
        return Vessel(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

}

extension Part {

    var partsEfficiency: Double {
        guard efficiencyParts?.isEmpty != true else { return 0 }
        guard let vessel = vessel else { return 0 }
        return Double(vessel.efficiencyParts
            .filter { $0.name != nil && efficiencyParts![$0.name!] != nil }
            .map { Int($0.count) * efficiencyParts![$0.name!]! }
            .reduce(0, combine: +))
    }

    var crewEfficiency: Double {
        guard let vessel = vessel else { return 0 }
        guard vessel.crewCount > 0 else { return 0 }
        let maxWorkspaceRatio = 3.0
        let workspaces = Double(vessel.efficiencyWorkspaceCount) + Double(vessel.crewCapacity) / 4
        let workspaceRatio = min(maxWorkspaceRatio, workspaces / Double(vessel.crewCount))
        let unboundedEfficiency = workspaceRatio * vessel.crewHappiness * (vessel.crewCareerFactor + Double(vessel.crewCount) * crewBonus)
        return min(maxEfficiency, max(minEfficiency, unboundedEfficiency))
    }

    var efficiency: Double {
        let minEfficiency = 0.25
        return efficiencyParts?.isEmpty != false ? crewEfficiency : min(minEfficiency, crewEfficiency + partsEfficiency)
    }

}
