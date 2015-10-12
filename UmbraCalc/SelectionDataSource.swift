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
import JeSuis
import UIKit

class SelectionDataSource<Element: NSManagedObject, Cell: UITableViewCell>: FetchedDataSource<Element, Cell>, UITableViewDelegate {

    var selectedModels = Set<Element>()
    var maximumSelectionCount = Int.max

    override init(sectionOffset: Int = 0) {
        super.init(sectionOffset: sectionOffset)
    }

    override func configureCell(cell: Cell, forElement model: Element) {
        cell.accessoryType = selectedModels.contains(model) ? .Checkmark : .None
    }

    override func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        super.controller(controller, didChangeObject: anObject, atIndexPath: indexPath, forChangeType: type, newIndexPath: newIndexPath)
        guard case .Delete = type else { return }
        selectedModels.remove(anObject as! Element)
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return selectedModels.contains(self[indexPath]) == true || selectedModels.count < maximumSelectionCount
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let model = self[indexPath]
        if selectedModels.contains(model) == true {
            deselectModel(model)
        } else {
            selectModel(model)
        }
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) as? Cell else { return }
        configureCell(cell, forElement: model)
    }

    func selectModel(model: Element) {
        selectedModels.insert(model)
    }

    func deselectModel(model: Element) {
        selectedModels.remove(model)
    }

}
