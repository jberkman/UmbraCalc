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

class Base: Vessel {

    func withKolony(kolony: Kolony?) -> Self {
        return withValue(kolony, forKey: "kolony")
    }

}

extension Base {

    override class var segueTypeNoun: String { return "Base" }

}

extension ManagingObjectContext {

    func insertBase() -> Base? {
        guard let managedObjectContext = managedObjectContext,
            entity = NSEntityDescription.entityForName(Base.segueTypeNoun, inManagedObjectContext: managedObjectContext) else { return nil }
        return Base(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

}
