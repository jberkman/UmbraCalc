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
    var tableViewController: UITableViewController? {
        didSet {
            oldValue?.tableView.dataSource = nil
            tableViewController?.tableView.dataSource = self
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
                tableViewController?.tableView.reloadData()
            } catch let error as NSError {
                NSLog("Could not perform fetch: %@", error)
                fetchedResultsController = nil
            }
        }
    }

    var entities: [Entity]? { return fetchedResultsController?.fetchedObjects as? [Entity] }

    var selectedEntity: Entity? {
        didSet {
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if selectedEntity != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteEntityWithNotification:", name: willDeleteEntityNotification, object: selectedEntity!)
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: nil)
    }

    private func createFetchedResultsController() -> NSFetchedResultsController? {
        guard let managedObjectContext = managedObjectContext, fetchRequest = fetchRequest else { return nil }
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: cacheName)
    }

    func entityAtIndexPath(indexPath: NSIndexPath) -> Entity? {
        return fetchedResultsController?.objectAtIndexPath(indexPath) as? Entity
    }

    func indexPathOfEntity(entity: Entity) -> NSIndexPath? {
        return fetchedResultsController?.indexPathForObject(entity)
    }

    @objc private func willDeleteEntityWithNotification(notification: NSNotification) {
        guard tableViewController?.splitViewController?.collapsed == false else {
            selectedEntity = nil
            return
        }

        guard let entity = entities?.lazy.filter({ $0 != self.selectedEntity }).first,
            indexPath = indexPathOfEntity(entity) else {
                selectedEntity = nil
                guard let empty = tableViewController?.storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController") else { return }
                tableViewController?.showDetailViewController(empty, sender: self)
                return
        }

        (tableViewController as? MasterTableViewController)?.showDetailViewControllerForEntityAtIndexPath(indexPath)
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
        tableViewController?.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableViewController?.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        case .Delete:
            tableViewController?.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)

        default:
            break
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableViewController?.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)

        case .Delete:
            tableViewController?.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)

        case .Update:
            guard let cell = tableViewController?.tableView.cellForRowAtIndexPath(indexPath!) as? Cell else { break }
            configureCell?(cell: cell, entity: entityAtIndexPath(indexPath!)!)

        case .Move:
            tableViewController?.tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableViewController?.tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableViewController?.tableView.endUpdates()
    }

}
