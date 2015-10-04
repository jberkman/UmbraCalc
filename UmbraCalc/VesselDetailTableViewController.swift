//
//  VesselDetailTableViewController.swift
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

class VesselDetailTableViewController: UITableViewController {

    private class PartDataSource: FetchedDataSource<Part, StepperTableViewCell> {

        var vessel: Vessel? {
            didSet {
                managedObjectContext = vessel?.managedObjectContext
                fetchRequest.predicate = vessel == nil ? nil : NSPredicate(format: "vessel = %@", vessel!)
            }
        }

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")
        var selectionRequiresCrewCapacity = false

        override init(sectionOffset: Int = 0) {
            super.init(sectionOffset: sectionOffset)
            reuseIdentifier = "stepperCell"
            fetchRequest.sortDescriptors = [Vessel.nameSortDescriptor]
        }

        override func configureCell(cell: PartDataSource.Cell, forModel part: Model) {
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
            reloadTableView()
        }

    }

    private class CrewDataSource: FetchedDataSource<Crew, UITableViewCell> {

        var vessel: Vessel? {
            didSet {
                managedObjectContext = vessel?.managedObjectContext
                fetchRequest.predicate = vessel == nil ? nil : NSPredicate(format: "part.vessel == %@", vessel!)
            }
        }

        override init(sectionOffset: Int = 0) {
            super.init(sectionOffset: sectionOffset)
            reuseIdentifier = "crewCell"
            fetchRequest.sortDescriptors = [Crew.nameSortDescriptor]
        }

        override func configureCell(cell: UITableViewCell, forModel crew: Crew) {
            cell.textLabel?.text = crew.displayName
            cell.detailTextLabel?.text = crew.part?.displayName
        }
        
    }

    @IBOutlet weak var crewCapacityLabel: UILabel!
    @IBOutlet weak var livingSpacesLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var workspacesLabel: UILabel!

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    private var hasAppeared = false

    private lazy var dataSource: StoryboardDelegatedDataSource = StoryboardDelegatedDataSource(dataSource: self)
    private lazy var partsDataSource = PartDataSource(sectionOffset: 1)
    private lazy var crewDataSource = CrewDataSource(sectionOffset: 2)

    var vessel: Vessel? {
        didSet {
            partsDataSource.vessel = vessel
            crewDataSource.vessel = vessel
            navigationItem.title = "\(vessel?.dynamicType.modelName ?? Vessel.modelName) Details"
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "StepperTableViewCell", bundle: nil), forCellReuseIdentifier: partsDataSource.reuseIdentifier)
        dataSource.registerDataSource(partsDataSource)
        partsDataSource.tableView = tableView

        tableView.registerClass(Value1TableViewCell.self, forCellReuseIdentifier: crewDataSource.reuseIdentifier)
        dataSource.registerDataSource(crewDataSource)
        crewDataSource.tableView = tableView

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        if partsDataSource.fetchedResultsController == nil {
            partsDataSource.reloadData()
        }
        if crewDataSource.fetchedResultsController == nil {
            crewDataSource.reloadData()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        guard vessel?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Part.showListSegueIdentifier:
            let partNodeList = segue.destinationViewController as! PartNodeListTableViewController
            partNodeList.navigationItem.leftBarButtonItem = partNodeList.cancelButtonItem

        case Part.showSegueIdentifier:
            let indexPath = sender as? NSIndexPath ?? tableView.indexPathForCell(sender as! UITableViewCell)!
            let partDetail = segue.destinationViewController as! PartDetailTableViewController
            partDetail.part = partsDataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

    @IBAction func cancelPart(segue: UIStoryboardSegue) { }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        func showDetailForPart(part: Part) {
            guard let indexPath = partsDataSource.indexPathForModel(part) else { return }
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

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = vessel?.name

        crewCapacityLabel.text = String(vessel?.crewCapacity ?? 0)
        livingSpacesLabel.text = String(vessel?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(vessel?.workspaceCount ?? 0)
        happinessLabel.text = percentFormatter.stringFromNumber(vessel?.crewHappiness ?? 0)
    }

}

extension VesselDetailTableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case partsDataSource.sectionOffset:
            performSegueWithIdentifier(Part.showSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))

        default:
            break
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case partsDataSource.sectionOffset, crewDataSource.sectionOffset:
            return 44

        default:
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0 // super.tableView(tableView, indentationLevelForRowAtIndexPath: storyboardIndexPath(indexPath))
    }

}

extension VesselDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        vessel?.name = textField.text
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
