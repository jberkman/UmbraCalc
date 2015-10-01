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

protocol ManagingObjectContext {
    var managedObjectContext: NSManagedObjectContext? { get }
}

protocol MutableManagingObjectContext: ManagingObjectContext {
    var managedObjectContext: NSManagedObjectContext? { get set }
}

protocol ManagingObjectContextContainer {
    func setManagingObjectContext(managingObjectContext: ManagingObjectContext)
}

extension ManagingObjectContextContainer where Self: MutableManagingObjectContext {

    mutating func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        managedObjectContext = managingObjectContext.managedObjectContext
    }

}
