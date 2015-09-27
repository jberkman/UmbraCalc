//
//  FetchedDataSource.swift
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
import UIKit

class FetchedDataSource<Entity: NSManagedObject, Cell: UITableViewCell>: NSObject, ManagingObjectContext, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    var reuseIdentifier = "reuseIdentifier"
    var configureCell: ((cell: Cell, entity: Entity) -> Void)?
    var tableView: UITableView? {
        didSet {
            tableView?.dataSource = self
        }
    }

    var sectionNameKeyPath: String? {
        didSet {
            fetchedResultsController = createFetchedResultsController()
        }
    }

    var cacheName: String? {
        didSet {
            fetchedResultsController = createFetchedResultsController()
        }
    }

    var managedObjectContext: NSManagedObjectContext? {
        didSet {
            fetchedResultsController = createFetchedResultsController()
        }
    }

    var fetchRequest: NSFetchRequest? = nil {
        didSet {
            fetchedResultsController = createFetchedResultsController()
        }
    }

    private(set) var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            do {
                try fetchedResultsController?.performFetch()
                fetchedResultsController?.delegate = self
                tableView?.reloadData()
            } catch let error as NSError {
                NSLog("Could not perform fetch: %@", error)
                fetchedResultsController = nil
            }
        }
    }

    private func createFetchedResultsController() -> NSFetchedResultsController? {
        guard let managedObjectContext = managedObjectContext, fetchRequest = fetchRequest else { return nil }
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }

    func entityAtIndexPath(indexPath: NSIndexPath) -> Entity? {
        return fetchedResultsController?.objectAtIndexPath(indexPath) as? Entity
    }

    // extension FetchedTableViewController: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.sections![section].numberOfObjects
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
        configureCell?(cell: cell, entity: entityAtIndexPath(indexPath)!)
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
            entityAtIndexPath(indexPath)?.deleteEntity()

        default:
            break
        }
    }

    // extension FetchedTableViewController: UIFetchedResultsControllerDelegate
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView?.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView?.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        case .Delete:
            tableView?.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        default:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)

        case .Delete:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)

        case .Update:
            guard let cell = tableView?.cellForRowAtIndexPath(indexPath!) as? Cell else { break }
            configureCell?(cell: cell, entity: entityAtIndexPath(indexPath!)!)

        case .Move:
            tableView?.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView?.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView?.endUpdates()
    }

}
