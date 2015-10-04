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

class Vessel: NamedEntity {

    @warn_unused_result
    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

    @warn_unused_result
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

    var crew: Set<Crew> {
        return (parts as? Set<Part>)?.flatMap { $0.crew as? Set<Crew> }.reduce(Set()) { $0.union($1) } ?? Set()
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

    var activeResourceConverterCount: Int {
        return partSum { $0.activeResourceConverterCount }
    }

    var efficiencyActiveResourceConverterCount: Int {
        return activeResourceConverterCount
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

extension Vessel: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "Vessel" }

}
