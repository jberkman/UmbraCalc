//
//  Station.swift
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

class Station: Vessel {

// Insert code here to add functionality to your managed object subclass

}

extension Station {

    override class var segueTypeNoun: String { return "Station" }

}

extension ManagingObjectContext {

    func insertStation() -> Station? {
        guard let managedObjectContext = managedObjectContext,
            entity = NSEntityDescription.entityForName(Station.segueTypeNoun, inManagedObjectContext: managedObjectContext) else { return nil }
        return Station(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

}
