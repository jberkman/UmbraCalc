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

import Apropos
import Balsa
import Foundation
import CoreData

class Vessel: NamedEntity {

    @NSManaged var parts: NSSet?
    @NSManaged private var primitiveScopeGroup: ScopedEntity?

    private var partsSet: Set<Part> {
        return parts as? Set<Part> ?? Set()
    }

    var containingKolonizingCollection: KolonizingCollectionType? {
        return nil
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveScopeGroup = self
    }

    @warn_unused_result
    func withParts<S: SequenceType where S.Generator.Element == Part>(parts: S) -> Self {
        return withValue(Set(parts), forKey: "parts")
    }

    override func setScopeNeedsUpdate() {
        super.setScopeNeedsUpdate()
        partsSet.forEach { $0.setScopeNeedsUpdate() }
    }

}

extension Vessel: ResourceConvertingCollectionType {

    var resourceConvertingCollection: AnyForwardCollection<ResourceConverting> {
        return AnyForwardCollection(partsSet.flatMap { $0.resourceConvertingCollection })
    }

}

extension Vessel: CrewingCollectionType {

    var crewingCollection: AnyForwardCollection<Crewing> {
        return AnyForwardCollection(partsSet.flatMap { $0.crewingCollection })
    }

}

extension Vessel: KolonizingCollectionType {

    var kolonizingCollection: AnyForwardCollection<Kolonizing> {
        return AnyForwardCollection(partsSet.map { $0 as Kolonizing })
    }

}

extension Vessel: CrewableCollectionType { }

extension Vessel: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "Vessel" }

}
