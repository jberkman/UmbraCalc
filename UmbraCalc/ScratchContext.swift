//
//  ScratchContext.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-01.
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

class ScratchContext: ManagingObjectContext {

    let managedObjectContext: NSManagedObjectContext?

    init(parentContext: ManagingObjectContext, concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) {
        managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        managedObjectContext!.parentContext = parentContext.managedObjectContext
    }
    
}
