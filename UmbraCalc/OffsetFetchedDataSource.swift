//
//  OffsetFetchedDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-06.
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

class OffsetFetchedDataSource<Model: NSManagedObject, Cell: UITableViewCell>: FetchedDataSource<Model, Cell>, OffsettableDataSource {

    let sectionOffset: Int

    init(sectionOffset: Int) {
        assert(sectionOffset >= 0)
        self.sectionOffset = sectionOffset
        super.init()
    }

    func modelAtIndexPath(indexPath: NSIndexPath) -> OffsetFetchedDataSource.Model {
        return super.modelAtIndexPath(indexPath.insetSectionBy(sectionOffset))
    }

    func indexPathForModel(model: Model) -> NSIndexPath? {
        return super.indexPathForModel(model)?.offsetSectionBy(sectionOffset)
    }

    func reloadTableView() {
        tableView.reloadSections(NSIndexSet(index: sectionOffset), withRowAnimation: .Fade)
    }

    // extension UITableViewDataSource where Self: FetchableDataSource {

    @objc override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.sections![section - sectionOffset].numberOfObjects
    }

    @objc override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return super.tableView(tableView, cellForRowAtIndexPath: indexPath.insetSectionBy(sectionOffset))
    }

    @objc override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        fatalError("\(__FUNCTION__) should be handled by delegating data source.")
    }

    @objc override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        fatalError("\(__FUNCTION__) should be handled by delegating data source.")
    }

    @objc override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        fatalError("\(__FUNCTION__) should be handled by delegating data source.")
    }

    @objc override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        fatalError("\(__FUNCTION__) should be handled by delegating data source.")
    }

    @objc override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            modelAtIndexPath(indexPath).deleteEntity()

        default:
            break
        }
    }

    // extension NSFetchedResultsControllerDelegate where Self: FetchableDataSource {

    @objc override func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        super.controller(controller, didChangeSection: sectionInfo, atIndex: sectionIndex + sectionOffset, forChangeType: type)
    }

    override func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        super.controller(controller, didChangeObject: anObject, atIndexPath: indexPath?.offsetSectionBy(sectionOffset), forChangeType: type, newIndexPath: newIndexPath?.offsetSectionBy(sectionOffset))
    }
    
}
