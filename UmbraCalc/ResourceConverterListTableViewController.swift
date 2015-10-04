//
//  ResourceConverterListTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-05.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import UIKit

class ResourceConverterListTableViewController: UITableViewController {

    private class DataSource: FetchedDataSource<ResourceConverter, UITableViewCell> {

        private func textLabelForModel(model: DataSource.Model) -> String? {
            guard model.part?.crewCapacity == 0 else { return model.name }
            let capacity = model.part?.count ?? 0
            return "\(model.displayName) (\(model.activeCount) of \(capacity))"
        }

        private override func configureCell(cell: DataSource.Cell, forModel resourceConverter: DataSource.Model) {
            cell.textLabel?.text = textLabelForModel(resourceConverter)

            let inputs = resourceConverter.inputResources.keys.sort().joinWithSeparator(" + ")
            let outputs = resourceConverter.outputResources.keys.sort().joinWithSeparator(" + ")
            cell.detailTextLabel?.text = "\(inputs) -> \(outputs)"

            if resourceConverter.part?.crewCapacity > 0 {
                if !(cell.accessoryView is UISwitch) {
                    let toggle = UISwitch()
                    toggle.addTarget(self, action: "toggleDidChangeValue:", forControlEvents: .ValueChanged)
                    cell.accessoryView = toggle
                }
                (cell.accessoryView as! UISwitch).on = resourceConverter.activeCount > 0
            } else {
                if !(cell.accessoryView is UIStepper) {
                    let stepper = UIStepper()
                    stepper.addTarget(self, action: "stepperDidChangeValue:", forControlEvents: .ValueChanged)
                    cell.accessoryView = stepper
                }
                let stepper = cell.accessoryView as! UIStepper
                stepper.value = Double(resourceConverter.activeCount)
                stepper.maximumValue = Double(resourceConverter.part?.count ?? 0)
            }
        }

        private func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            return "Activating converters slightly reduces crew efficiency of this station or kolony."
        }

        @objc private func toggleDidChangeValue(sender: UISwitch) {
            guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
            modelAtIndexPath(indexPath).activeCount = sender.on ? 1 : 0
        }

        @objc private func stepperDidChangeValue(sender: UIStepper) {
            guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
            let resourceConverter = modelAtIndexPath(indexPath)
            resourceConverter.activeCount = Int16(sender.value)
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text = textLabelForModel(resourceConverter)
        }

    }

    private var dataSource = DataSource()

    var part: Part? {
        didSet {
            dataSource.managedObjectContext = part?.managedObjectContext
            dataSource.fetchRequest.predicate = part == nil ? nil : NSPredicate(format: "part = %@", part!)
            guard isViewLoaded() else { return }
            dataSource.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchRequest.sortDescriptors = [ResourceConverter.nameSortDescriptor]
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        dataSource.reloadData()
    }
}
