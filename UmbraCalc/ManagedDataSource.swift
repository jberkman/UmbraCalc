//
//  ManagedDataSource.swift
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

protocol ManagedDataSourceDelegate: class {
    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity)
}

class ManagedDataSource<Entity: NSManagedObject, Cell: UITableViewCell>: NSObject, ManagingObjectContext, ManagedDataSourceType, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    let fetchRequest = NSFetchRequest()
    var reuseIdentifier = "reuseIdentifier"
    var sectionNameKeyPath: String?
    var cacheName: String?

    var tableView: UITableView! {
        didSet {
            oldValue?.dataSource = nil
            tableView?.dataSource = self
        }
    }

    var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }

    var managedObjectContext: NSManagedObjectContext?

    weak var delegate: ManagedDataSourceDelegate?

    func configureCell(cell: Cell, forEntity entity: Entity) {
        delegate?.managedDataSource(self, configureCell: cell, forEntity: entity)
    }

    // extension UITableViewDataSource where Self: ManagedDataSourceType {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.sections![section].numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
        configureCell(cell, forEntity: entityAtIndexPath(indexPath))
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController!.sections![section].name
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController!.sectionForSectionIndexTitle(title, atIndex: index)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            entityAtIndexPath(indexPath).deleteEntity()

        default:
            break
        }
    }

    // extension NSFetchedResultsControllerDelegate where Self: ManagedDataSourceType {

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        default:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)

        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)

        case .Update:
            guard let cell = tableView.cellForRowAtIndexPath(indexPath!) as? Cell else { break }
            configureCell(cell, forEntity: entityAtIndexPath(indexPath!))

        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
