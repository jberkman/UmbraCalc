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

    @warn_unused_result
    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

    @warn_unused_result
    func withBases<S: SequenceType where S.Generator.Element == Base>(bases: S) -> Self {
        return withValue(Set(bases), forKey: "bases")
    }

    private var basesSet: Set<Base> {
        return bases as? Set<Base> ?? Set()
    }

}

extension Kolony: ResourceConvertingCollectionType {

    var resourceConvertingCollection: AnyForwardCollection<ResourceConverting> {
        return AnyForwardCollection(basesSet.flatMap { $0.resourceConvertingCollection })
    }

}

extension Kolony: CrewingCollectionType {

    var crewingCollection: AnyForwardCollection<Crewing> {
        return AnyForwardCollection(basesSet.flatMap { $0.crewingCollection })
    }

}

extension Kolony: KolonizingCollectionType {

    var kolonizingCollection: AnyForwardCollection<Kolonizing> {
        return AnyForwardCollection(basesSet.flatMap { $0.kolonizingCollection })
    }
    
}

extension Kolony: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "Kolony" }

}
