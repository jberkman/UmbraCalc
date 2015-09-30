//
//  ManagedDataSourceType.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-28.
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

protocol ManagedDataSourceType: class {

    typealias Entity: NSManagedObject
    typealias Cell: UITableViewCell

    var fetchRequest: NSFetchRequest { get }
    var reuseIdentifier: String { get }
    var sectionNameKeyPath: String? { get }
    var cacheName: String? { get }

    var tableView: UITableView! { get }

    var fetchedResultsController: NSFetchedResultsController? { get set }

    func configureCell(cell: Cell, forEntity entity: Entity)

}

extension ManagedDataSourceType {

    var entities: [Entity]? { return fetchedResultsController?.fetchedObjects as? [Entity] }

    func entityAtIndexPath(indexPath: NSIndexPath) -> Entity {
        return fetchedResultsController!.objectAtIndexPath(indexPath) as! Entity
    }

    func indexPathOfEntity(entity: Entity) -> NSIndexPath? {
        return fetchedResultsController?.indexPathForObject(entity)
    }

}

extension ManagedDataSourceType where Self: ManagingObjectContext {

    func reloadData() {
        guard let managedObjectContext = managedObjectContext else { return }
        if fetchRequest.entity == nil {
            fetchRequest.entity = managedObjectContext.persistentStoreCoordinator?.managedObjectModel.entities.lazy.filter {
                $0.managedObjectClassName == NSStringFromClass(Entity.self)
                }.first
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
        do {
            try fetchedResultsController?.performFetch()
            tableView.reloadData()
        } catch let error as NSError {
            NSLog("Could not perform fetch: %@", error)
            fetchedResultsController = nil
        }
    }
    
}
