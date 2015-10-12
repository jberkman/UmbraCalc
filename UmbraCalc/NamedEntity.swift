//
//  NamedEntity.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
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

class NamedEntity: ScopedEntity {

    static let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)

    @NSManaged private var primitiveName: String?

    dynamic var name: String? {
        get {
            willAccessValueForKey("name")
            let ret = primitiveName
            didAccessValueForKey("name")
            return ret
        }
        set {
            willChangeValueForKey("name")
            primitiveName = newValue
            setScopeNeedsUpdate()
            didChangeValueForKey("name")
        }
    }

    override var scopeKey: String {
        return [entity.name!, name ?? "", creationDateScopeKey].joinWithSeparator("-")
    }

    @warn_unused_result
    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

}

extension ModelNaming where Self: NamedEntity {

    var displayName: String {
        guard name?.isEmpty == false else { return "Unnamed \(modelName)" }
        return name!
    }

}

// http://www.openradar.me/radar?id=6421938515738624
// extension NamedEntity: MutableNamedType { }
