//
//  NamedEntity.swift
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

import Foundation
import CoreData

class NamedEntity: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

}

// http://www.openradar.me/radar?id=6421938515738624
// extension NamedEntity: MutableNamedType { }

extension ManagedDataSourceType where Entity: NamedEntity {

    var nameSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }

    func configureCell(cell: Cell, forNamedEntity namedEntity: Entity) {
        cell.textLabel!.text = namedEntity.name
    }
    
}