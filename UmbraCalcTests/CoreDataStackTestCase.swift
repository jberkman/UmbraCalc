//
//  CoreDataStackTestCase.swift
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
import XCTest

@testable import UmbraCalc

class CoreDataStackTestCase: XCTestCase {

    var coreDataStack: CoreDataStack!

    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStack(persistentStoreType: NSInMemoryStoreType)
    }
    
    override func tearDown() {
        coreDataStack = nil
        super.tearDown()
    }

}

extension CoreDataStackTestCase: ManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext? { return coreDataStack.managedObjectContext }

}
