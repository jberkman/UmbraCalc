//
//  PartListTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
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

class StepperCell: UITableViewCell {

    @IBOutlet weak var stepperTextLabel: UILabel!
    @IBOutlet weak var stepperDetailTextLabel: UILabel!

    private var minimumValue = 0.0
    private var maximumValue = 100.0

    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            guard let stepper = stepper else { return }
            minimumValue = stepper.minimumValue
            maximumValue = stepper.maximumValue
        }
    }

    override var textLabel: UILabel? {
        return stepperTextLabel
    }

    override var detailTextLabel: UILabel? {
        return stepperDetailTextLabel
    }

    override func prepareForReuse() {
        stepper.removeTarget(nil, action: nil, forControlEvents: .ValueChanged)
        stepper.hidden = false
        stepper.minimumValue = minimumValue
        stepper.maximumValue = maximumValue
    }
}

class PartListTableViewController: UITableViewController {

    private class DataSource: FetchedDataSource<Part, StepperCell> {

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")
        var selectionRequiresCrewCapacity = false

        override func configureCell(cell: DataSource.Cell, forModel part: Model) {
            cell.textLabel?.text = part.title
            let efficiency = "Efficiency: \(percentFormatter.stringFromNumber(part.efficiency)!)"
            if part.partNode?.crewCapacity > 0 {
                cell.detailTextLabel?.text = "Crew: \(part.crew?.count ?? 0) of \(part.crewCapacity) \(efficiency)"
                cell.stepper.hidden = true
            } else {
                cell.detailTextLabel?.text = "Count: \(part.count) \(efficiency)"
                cell.stepper.value = Double(part.count)
                cell.stepper.addTarget(self, action: "countStepperValueDidChange:", forControlEvents: .ValueChanged)
            }
        }

        @objc private func countStepperValueDidChange(sender: UIStepper) {
            guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
            modelAtIndexPath(indexPath).count = Int16(sender.value)

            guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        }
    }

    private(set) var selectedPart: DataSource.Model?

    private var dataSource = DataSource()

    var predicate: NSPredicate? {
        get { return dataSource.fetchRequest.predicate }
        set { dataSource.fetchRequest.predicate = newValue }
    }

    var vessel: Vessel? {
        didSet {
            dataSource.managedObjectContext = vessel?.managedObjectContext
            predicate = vessel == nil ? nil : NSPredicate(format: "vessel = %@", vessel!)
            navigationItem.title = vessel?.displayName ?? "Parts"
            guard isViewLoaded() else { return }
            dataSource.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else {
            guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
            return
        }
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Part.showListSegueIdentifier:
            let partNodeList = segue.destinationViewController as! PartNodeListTableViewController
            partNodeList.navigationItem.leftBarButtonItem = partNodeList.cancelButtonItem

        case Part.showSegueIdentifier:
            let indexPath = sender as? NSIndexPath ?? tableView.indexPathForCell(sender as! UITableViewCell)!
            let partDetail = segue.destinationViewController as! PartDetailTableViewController
            partDetail.part = dataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

    @IBAction func cancelPart(segue: UIStoryboardSegue) { }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        func showDetailForPart(part: Part) {
            guard let indexPath = dataSource.indexPathForModel(part) else { return }
            performSegueWithIdentifier(Part.showSegueIdentifier, sender: indexPath)
        }
        
        let partNodeList = segue.sourceViewController as! PartNodeListTableViewController
        guard let partNode = partNodeList.selectedPartNode else { return }

        if partNode.crewCapacity == 0, let existingPart = (vessel?.parts as? Set<Part>)?.lazy.filter({ $0.partName == partNode.name }).first {
            ++existingPart.count
            showDetailForPart(existingPart)
            return
        }

        guard let managedObjectContext = vessel?.managedObjectContext else { return }
        _ = try? Part(insertIntoManagedObjectContext: managedObjectContext).withPartName(partNode.name).withVessel(vessel!)

        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }

}
