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

class SelectionDataSource<Model: NSManagedObject, Cell: UITableViewCell>: FetchedDataSource<Model, Cell>, UITableViewDelegate {

    var selectedModels = Set<Model>()
    var maximumSelectionCount = Int.max
    weak var tableViewDelegate: UITableViewDelegate?

    override var tableView: UITableView! {
        didSet {
            oldValue?.delegate = nil
            tableView?.delegate = self
            super.tableView = tableView
        }
    }

    override func configureCell(cell: Cell, forModel model: Model) {
        cell.editingAccessoryType = selectedModels.contains(model) ? .Checkmark : .None
    }

    override func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        super.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
        guard case .Delete = type else { return }
        selectedModels.remove(anObject as! Model)
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard tableView.editing else { return false }
        return selectedModels.contains(modelAtIndexPath(indexPath)) == true || selectedModels.count < maximumSelectionCount
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView.editing else {
            tableViewDelegate?.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
            return
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model = modelAtIndexPath(indexPath)
        if selectedModels.contains(model) == true {
            selectedModels.remove(model)
        } else {
            selectedModels.insert(model)
        }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? Cell else { return }
        configureCell(cell, forModel: model)
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

}
