//
//  ScopedEntity.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-08.
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

class ScopedEntity: NSManagedObject {

    @NSManaged var creationDate: NSTimeInterval
    @NSManaged var modificationDate: NSTimeInterval
    @NSManaged var scope: String?
    @NSManaged var subscopes: NSSet?

    @NSManaged private var primitiveCreationDate: NSDate?
    @NSManaged private var primitiveModificationDate: NSDate?
    @NSManaged private var primitiveScope: String?
    @NSManaged var primitiveRootScope: ScopedEntity?

    var superscope: ScopedEntity? { return nil }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        primitiveCreationDate = NSDate()
        primitiveModificationDate = primitiveCreationDate
        primitiveScope = scopeKey
    }

    override func willSave() {
        super.willSave()
        primitiveModificationDate = NSDate()
    }

    var scopeDepth: Int {
        return superscope == nil ? 0 : (superscope!.scopeDepth + 1)
    }

    var creationDateScopeKey: String {
        return String(format: "%16llx", CLongLong(creationDate * 10_000))
    }

    var scopeKey: String {
        return "\(entity.name!)-\(creationDateScopeKey)"
    }

    func setScopeNeedsUpdate() {
        if let superscopeScope = superscope?.scope {
            scope = "\(superscopeScope)|\(scopeKey)"
        } else {
            scope = scopeKey
        }
    }

    var rootScope: ScopedEntity? {
        get {
            willAccessValueForKey("rootScope")
            let ret = primitiveRootScope
            didAccessValueForKey("rootScope")
            return ret
        }
        set {
            willChangeValueForKey("rootScope")
            primitiveRootScope = newValue
            setScopeNeedsUpdate()
            didChangeValueForKey("rootScope")
        }
    }

}
