//
//  Kolony.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-24.
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

class Kolony: NamedEntity {

    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

    func withBases<S: SequenceType where S.Generator.Element == Base>(bases: S) -> Self {
        return withValue(Set(bases), forKey: "bases")
    }

    private func baseSum(transform: (Base) -> Int) -> Int {
        return (bases as? Set<Base>)?.map(transform).reduce(0, combine: +) ?? 0
    }

    var crewCapacity: Int {
        return baseSum { $0.crewCapacity }
    }

    var crewCount: Int {
        return baseSum { $0.crewCount }
    }

    var livingSpaceCount: Int {
        return baseSum { $0.livingSpaceCount }
    }

    var workspaceCount: Int {
        return baseSum { $0.workspaceCount }
    }

    var crew: Set<Crew> {
        return (bases as? Set<Base>)?.flatMap { $0.crew }.reduce(Set()) { $0.union($1) } ?? Set()
    }

    var parts: Set<Part> {
        return (bases as? Set<Base>)?.flatMap { $0.parts as? Set<Part> }.reduce(Set()) { $0.union($1) } ?? Set()
    }

}

extension Kolony: ModelNaming, SegueableType, Segueable {
    class var modelName: String { return "Kolony" }
}

extension Base {
    
    override var happinessCrewCapacity: Int {
        return kolony?.crewCapacity ?? crewCapacity
    }

    override var happinessCrewCount: Int {
        return kolony?.crewCount ?? crewCount
    }

    override var happinessLivingSpaceCount: Int {
        return kolony?.livingSpaceCount ?? livingSpaceCount
    }

    override var efficiencyWorkspaceCount: Int {
        return kolony?.workspaceCount ?? workspaceCount
    }

    override var efficiencyParts: Set<Part> {
        return kolony?.parts ?? parts as? Set<Part> ?? Set()
    }

}
