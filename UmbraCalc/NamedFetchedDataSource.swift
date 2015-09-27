//
//  VesselFetchedDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
//  Copyright © 2015 jacob berkman. All rights reserved.
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
