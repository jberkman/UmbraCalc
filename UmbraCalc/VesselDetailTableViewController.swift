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
            cell.textLabel?.text = part.displayName
            cell.detailTextLabel?.text = part.displaySummary
            if part.crewed {
                cell.stepper.hidden = true
            } else {
                cell.stepper.value = Double(part.count)
                cell.stepper.addTarget(self, action: "countStepperValueDidChange:", forControlEvents: .ValueChanged)
            }
        }

        @objc private func countStepperValueDidChange(sender: UIStepper) {
            guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
            let part = modelAtIndexPath(indexPath)
            part.count = Int16(sender.value)
            (part.resourceConverters as? Set<ResourceConverter>)?.forEach { $0.activeCount = min($0.activeCount, part.count) }
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
    private lazy var partDataSource = PartDataSource(sectionOffset: 1)
    private lazy var crewDataSource = CrewDataSource(sectionOffset: 2)

    private let partsObserver = ObserverContext(keyPath: "parts")

    var vessel: Vessel? {
        didSet {
            oldValue?.removeObserver(self, context: partsObserver)
            vessel?.addObserver(self, context: partsObserver)
            partDataSource.vessel = vessel

            crewDataSource.managedObjectContext = vessel?.managedObjectContext
            crewDataSource.fetchRequest.predicate = vessel == nil ? nil : NSPredicate(format: "part.vessel == %@", vessel!)

            navigationItem.title = "\(vessel?.dynamicType.modelName ?? Vessel.modelName) Details"
            updateView()
        }
    }

    deinit {
        vessel?.removeObserver(self, context: partsObserver)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(UINib(nibName: "StepperTableViewCell", bundle: nil), forCellReuseIdentifier: partDataSource.reuseIdentifier)
        dataSource.registerDataSource(partDataSource)
        partDataSource.tableView = tableView

        tableView.registerClass(Value1TableViewCell.self, forCellReuseIdentifier: crewDataSource.reuseIdentifier)
        dataSource.registerDataSource(crewDataSource)
        crewDataSource.detailType = .Part
        crewDataSource.tableView = tableView

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateView()

        if partDataSource.fetchedResultsController == nil {
            partDataSource.reloadData()
        } else {
            partDataSource.reconfigureCells()
        }

        if crewDataSource.fetchedResultsController == nil {
            crewDataSource.reloadData()
        } else {
            crewDataSource.reconfigureCells()
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
            partDetail.part = partDataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        switch context {
        case &partsObserver.context:
            updateView()
            partDataSource.reconfigureCells()

        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

    @IBAction func cancelPart(segue: UIStoryboardSegue) { }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        func showDetailForPart(part: Part) {
            guard let indexPath = partDataSource.indexPathForModel(part) else { return }
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
        _ = try? Part(insertIntoManagedObjectContext: managedObjectContext).withVessel(vessel!).withPartName(partNode.name)

        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = vessel?.name

        crewCapacityLabel.text = String(vessel?.crewCapacity ?? 0)
        livingSpacesLabel.text = String(vessel?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(vessel?.workspaceCount ?? 0)
        happinessLabel.text = percentFormatter.stringFromNumber(vessel?.happiness ?? 0)
    }

}

extension VesselDetailTableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case partDataSource.sectionOffset:
            performSegueWithIdentifier(Part.showSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))

        default:
            break
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case partDataSource.sectionOffset, crewDataSource.sectionOffset:
            return 44

        default:
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == partDataSource.sectionOffset
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
