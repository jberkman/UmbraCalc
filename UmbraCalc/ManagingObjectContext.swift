//
//  ManagingObjectContext.swift
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

import CoreData

protocol ManagingObjectContext: class {
    var managedObjectContext: NSManagedObjectContext? { get }
}

protocol MutableManagingObjectContext: ManagingObjectContext {
    var managedObjectContext: NSManagedObjectContext? { get set }
}

protocol ManagingObjectContextContainer: class {
    func setManagingObjectContext(managingObjectContext: ManagingObjectContext)
}

extension ManagingObjectContextContainer where Self: MutableManagingObjectContext {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        managedObjectContext = managingObjectContext.managedObjectContext
    }

}

class ScratchContext: NSObject, ManagingObjectContext {

    let managedObjectContext: NSManagedObjectContext?

    init(parent: ManagingObjectContext, concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) {
        managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        managedObjectContext!.parentContext = parent.managedObjectContext
    }

}
