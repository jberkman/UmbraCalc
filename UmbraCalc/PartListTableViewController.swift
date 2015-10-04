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
            func superCell(view: UIView) -> UITableViewCell? {
                guard let superView = view.superview else { return nil }
                guard let cell = superView as? UITableViewCell else { return superCell(superView) }
                return cell
            }
            guard let cell = superCell(sender), indexPath = tableView.indexPathForCell(cell) else { return }
            modelAtIndexPath(indexPath).count = Int16(sender.value)
        }

    }

    typealias Model = DataSource.Model

    private(set) var selectedModel: Model?

    private(set) var dataSource: FetchedDataSource<DataSource.Model, DataSource.Cell> = DataSource()

    var vessel: Vessel? {
        didSet {
            managedObjectContext = vessel?.managedObjectContext
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
        guard dataSource.fetchedResultsController == nil else { return }
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Part.showListSegueIdentifier:
            let partNodeList = segue.destinationViewController as! PartNodeListTableViewController
            partNodeList.navigationItem.leftBarButtonItem = partNodeList.cancelButtonItem

        case Part.showSegueIdentifier:
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let partDetail = segue.destinationViewController as! PartDetailTableViewController
            partDetail.model = dataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

    private func showDetailForPart(part: Part) {
        guard let indexPath = dataSource.indexPathForModel(part) else { return }
        performSegueWithIdentifier(Part.showSegueIdentifier, sender: indexPath)
    }

    @IBAction func cancelPart(segue: UIStoryboardSegue) { }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        let partNodeList = segue.sourceViewController as! PartNodeListTableViewController
        guard let partNode = partNodeList.selectedModel else { return }

        if partNode.crewCapacity == 0, let existingPart = (vessel?.parts as? Set<Part>)?.lazy.filter({ $0.partName == partNode.name }).first {
            ++existingPart.count
            showDetailForPart(existingPart)
            return
        }

        guard let managedObjectContext = vessel?.managedObjectContext,
            part = try? Part(insertIntoManagedObjectContext: managedObjectContext).withPartName(partNode.name).withVessel(vessel!) else { return }
        managedObjectContext.processPendingChanges()
        showDetailForPart(part)
    }

}

extension PartListTableViewController: MutableManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }
    
}

extension PartListTableViewController: ModelSelecting { }

extension PartListTableViewController: Predicating {

    var predicate: NSPredicate? {
        get { return dataSource.fetchRequest.predicate }
        set { dataSource.fetchRequest.predicate = newValue }
    }

}

extension PartListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}
