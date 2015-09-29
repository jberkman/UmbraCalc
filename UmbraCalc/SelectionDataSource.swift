//
//  SelectionDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-29.
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

class SelectionDataSource<Entity: NSManagedObject, Cell: UITableViewCell>: ManagedDataSource<Entity, Cell>, UITableViewDelegate {

    var selectedEntities: Set<Entity>?
    var maxCount = Int.max
    weak var tableViewDelegate: UITableViewDelegate?

    override var tableView: UITableView! {
        didSet {
            oldValue?.delegate = nil
            tableView?.delegate = self
            super.tableView = tableView
        }
    }

    override func configureCell(cell: Cell, forEntity entity: Entity) {
        cell.editingAccessoryType = selectedEntities?.contains(entity) == true ? UITableViewCellAccessoryType.Checkmark : .None
        super.configureCell(cell, forEntity: entity)
    }

    override func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        super.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
        guard case .Delete = type else { return }
        selectedEntities?.remove(anObject as! Entity)
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard tableView.editing else {
            return tableViewDelegate?.tableView?(tableView, shouldHighlightRowAtIndexPath: indexPath) != false
        }
        return selectedEntities?.contains(entityAtIndexPath(indexPath)) == true || selectedEntities?.count < maxCount - 1
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView.editing else {
            tableViewDelegate?.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let entity = entityAtIndexPath(indexPath)
        if selectedEntities?.contains(entity) == true {
            selectedEntities?.remove(entity)
        } else {
            selectedEntities?.insert(entity)
        }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? Cell else { return }
        configureCell(cell, forEntity: entity)
    }

}
