//
//  FetchedDataSource.swift
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

class FetchedDataSource<Model: NSManagedObject, Cell: UITableViewCell>: NSObject, FetchableDataSource, OffsettableDataSource, NSFetchedResultsControllerDelegate, UITableViewDataSource {

    let fetchRequest = NSFetchRequest()
    var reuseIdentifier = "reuseIdentifier"
    var sectionNameKeyPath: String?
    var cacheName: String?

    var tableView: UITableView!

    let sectionOffset: Int

    init(sectionOffset: Int = 0) {
        assert(sectionOffset >= 0)
        self.sectionOffset = sectionOffset
        super.init()
    }

    var fetchedResultsController: NSFetchedResultsController? {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }

    var managedObjectContext: NSManagedObjectContext?

    func modelAtIndexPath(indexPath: NSIndexPath) -> Model {
        return fetchedResultsController!.objectAtIndexPath(indexPath.insetSectionBy(sectionOffset)) as! Model
    }

    func indexPathForModel(model: Model) -> NSIndexPath? {
        return fetchedResultsController?.indexPathForObject(model)?.offsetSectionBy(sectionOffset)
    }

    func reloadTableView() {
        // tableView.reloadSections(NSIndexSet(index: sectionOffset), withRowAnimation: .Fade)
        tableView.reloadData()
    }

    func configureCell(cell: Cell, forModel model: Model) { }

    // extension UITableViewDataSource where Self: FetchableDataSource {

    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedResultsController?.sections?.count ?? 0) + sectionOffset
    }

    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.sections![section - sectionOffset].numberOfObjects ?? 0
    }

    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! Cell
        configureCell(cell, forModel: modelAtIndexPath(indexPath))
        return cell
    }

    @objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController!.sections![section - sectionOffset].name
    }

    @objc func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return fetchedResultsController?.sectionIndexTitles
    }

    @objc func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController!.sectionForSectionIndexTitle(title, atIndex: index - sectionOffset)
    }

    @objc func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            modelAtIndexPath(indexPath).deleteEntity()

        default:
            break
        }
    }

    // extension NSFetchedResultsControllerDelegate where Self: FetchableDataSource {

    @objc func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }

    @objc func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex + sectionOffset), withRowAnimation: .Fade)

        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex + sectionOffset), withRowAnimation: .Fade)

        default:
            break
        }
    }

    @objc func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!.offsetSectionBy(sectionOffset)], withRowAnimation: .Fade)

        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!.offsetSectionBy(sectionOffset)], withRowAnimation: .Fade)

        case .Update:
            guard let cell = tableView.cellForRowAtIndexPath(indexPath!.offsetSectionBy(sectionOffset)) as? Cell else { break }
            configureCell(cell, forModel: anObject as! Model)

        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!.offsetSectionBy(sectionOffset)], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!.offsetSectionBy(sectionOffset)], withRowAnimation: .Fade)
        }
    }
    
    @objc func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}
