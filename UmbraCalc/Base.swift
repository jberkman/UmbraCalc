//
//  Base.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
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

private let defaultParts = [ "MKV_AgModule", "MKV_HabModule", "MKV_Lander", "MKV_Pod", "MKV_PowerPack", "MKV_Workshop" ]

class Base: Vessel {

    @NSManaged private var primitiveKolony: Kolony?
    @NSManaged private var primitiveScopeGroup: ScopedEntity?

    dynamic var kolony: Kolony? {
        get {
            willAccessValueForKey("kolony")
            let ret = primitiveKolony
            didAccessValueForKey("kolony")
            return ret
        }
        set {
            willChangeValueForKey("kolony")
            primitiveKolony = newValue
            rootScope = newValue?.rootScope
            didChangeValueForKey("kolony")
        }
    }

    override var rootScope: ScopedEntity? {
        get {
            return super.rootScope
        }
        set {
            super.rootScope = newValue
            parts?.forEach { ($0 as! ScopedEntity).rootScope = newValue }
        }
    }

    override var superscope: ScopedEntity? {
        return kolony
    }

    override var containingKolonizingCollection: KolonizingCollectionType? {
        return kolony
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveScopeGroup = self
    }

    @warn_unused_result
    func withKolony(kolony: Kolony?) -> Self {
        return withValue(kolony, forKey: "kolony")
    }

    @warn_unused_result
    func withDefaultParts() throws -> Self {
        guard let managedObjectContext = managedObjectContext else { return self }
        return try withParts(defaultParts.map { try Part(insertIntoManagedObjectContext: managedObjectContext).withPartFileName($0) })
    }

}

extension Base {

    override class var modelName: String { return "Base" }

}
