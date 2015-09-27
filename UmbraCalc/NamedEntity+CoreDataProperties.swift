//
//  NamedEntity+CoreDataProperties.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
//  Copyright © 2015 jacob berkman. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension NamedEntity {

    @NSManaged var name: String?

}
