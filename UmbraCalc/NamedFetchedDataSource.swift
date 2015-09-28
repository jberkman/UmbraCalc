//
//  VesselFetchedDataSource.swift
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
import UIKit

class NamedEntityFetchedDataSource<Entity: NamedEntity, Cell: UITableViewCell>: FetchedDataSource<Entity, Cell> {

    override init() {
        super.init()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        configureCell = { (cell: Cell, entity: Entity) in
            cell.textLabel!.text = entity.name
        }
    }

}

class NamedTypeFetchedDataSource<Entity: NSManagedObject, Cell: UITableViewCell where Entity: NamedType>: FetchedDataSource<Entity, Cell> {

    override init() {
        super.init()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        configureCell = { (cell: Cell, entity: Entity) in
            cell.textLabel!.text = entity.name
        }
    }
    
}
