//
//  ManagingObjectContext.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
//  Copyright © 2015 jacob berkman. All rights reserved.
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
