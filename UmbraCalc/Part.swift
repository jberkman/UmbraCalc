//
//  Part.swift
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

class Part: NSManagedObject {

    private dynamic var cachedPartNode: PartNode?
    private var partNode: PartNode? {
        guard let name = partName else { return nil }
        if cachedPartNode?.name != name {
            cachedPartNode = PartNode(named: name)
        }
        return cachedPartNode
    }

    func withCount(count: Int) -> Self {
        return withValue(count, forKey: "count")
    }

    func withAdditionalCount(additionalCount: Int) -> Self {
        return withCount(Int(count) + additionalCount)
    }

    func withVessel(vessel: Vessel?) -> Self {
        return withValue(vessel, forKey: "vessel")
    }

    func withCrew<S: SequenceType where S.Generator.Element == Crew>(crew: S) -> Self {
        return withValue(Set(crew), forKey: "crew")
    }

    var name: String? { return partNode?.name }
    var title: String? { return partNode?.title }
    var crewCapacity: Int { return Int(count) * (partNode?.crewCapacity ?? 0) }
    var crewBonus: Double { return partNode?.crewBonus ?? 0 }
    var maxEfficency: Double { return partNode?.maxEfficiency ?? 0 }
    var workspaceCount: Int { return Int(count) * (partNode?.workspaceCount ?? 0) }
    var livingSpaceCount: Int { return Int(count) * (partNode?.livingSpaceCount ?? 0) }
    var primarySkill: String? { return partNode?.primarySkill }
    var secondarySkill: String? { return partNode?.secondarySkill }
    var efficiencyParts: [String: Int]? { return partNode?.efficiencyParts ?? [:] }

    private func crewSum(transform: (Crew) -> Int) -> Int {
        return (crew as? Set<Crew>)?.map(transform).reduce(0, combine: +) ?? 0
    }

    private func crewSum(transform: (Crew) -> Double) -> Double {
        return (crew as? Set<Crew>)?.map(transform).reduce(0.0, combine: +) ?? 0
    }

    var crewCareerFactor: Double {
        return crewSum { $0.careerFactor }
    }

}

extension Part: NamedType { }

extension ManagingObjectContext {

    func insertPartWithPartName(partName: String) -> Part? {
        guard let managedObjectContext = managedObjectContext,
            entity = NSEntityDescription.entityForName("Part", inManagedObjectContext: managedObjectContext) else { return nil }
        let part = Part(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
        part.partName = partName
        return part.withCount(1)
    }

}

extension Crew {

    var careerFactor: Double {
        guard let part = part else { return 0 }
        let starFactor = max(0.1, Double(starCount) / 2)
        let careerMultiplier = career == part.primarySkill ? 1.5 : career == part.secondarySkill ? 1 : 0.5
        return starFactor * careerMultiplier
    }

}
