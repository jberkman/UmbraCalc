//
//  CoreDataExtensions.swift
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

import CoreData
import Foundation

let willDeleteEntityNotification = "UmbraCalc.willDeleteEntityNotification"
let didDeleteEntityNotification = "UmbraCalce.didDeleteEntityNotification"

extension NSManagedObject {

    func deleteEntity() {
        NSNotificationCenter.defaultCenter().postNotificationName(willDeleteEntityNotification, object: self)
        managedObjectContext?.deleteObject(self)
        NSNotificationCenter.defaultCenter().postNotificationName(didDeleteEntityNotification, object: self)
    }

    func saveToParentContext<Entity: NSManagedObject>(completion: ((Entity?) -> Void)?) throws {
        guard let parentContext = managedObjectContext?.parentContext else {
            completion?(nil)
            return
        }
        try managedObjectContext?.obtainPermanentIDsForObjects([self])
        try managedObjectContext?.save()
        guard let completion = completion else { return }
        let ID = objectID
        parentContext.performBlock {
            completion(parentContext.objectWithID(ID) as? Entity)
        }
    }

}
