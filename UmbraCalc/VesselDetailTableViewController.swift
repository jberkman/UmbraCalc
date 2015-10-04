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

    typealias Model = Vessel

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var crewCell: UITableViewCell!
    @IBOutlet weak var livingSpacesLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var partCountLabel: UILabel!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
    @IBOutlet weak var workspacesLabel: UILabel!

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    private var hasAppeared = false

    var managedObjectContext: NSManagedObjectContext?

    var model: Model? {
        didSet {
            // Prevent vessel from being faulted
            managedObjectContext = model?.managedObjectContext
            navigationItem.title = "\(model?.dynamicType.modelName ?? Vessel.modelName) Details"
            updateView()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        guard model?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case Crew.showListSegueIdentifier:
            return model?.crewCount > 0

        default:
            return true
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.showListSegueIdentifier:
            let crewSelection = segue.destinationViewController as! CrewSelectionTableViewController
            crewSelection.setManagingObjectContext(self)

            guard let vessel = model else { return }
            crewSelection.predicate = NSPredicate(format: "part.vessel = %@", vessel)
            crewSelection.navigationItem.title = "\(vessel.displayName) Crew"

        case Part.showListSegueIdentifier:
            let partList = segue.destinationViewController as! PartListTableViewController
            partList.vessel = model

        case Vessel.saveSegueIdentifier, Model.saveSegueIdentifier:
            model?.name = nameTextField.text

        default:
            break
        }
    }

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = model?.name

        partCountLabel.text = String(model?.partCount ?? 0)
        let crewCount = model?.crewCount ?? 0
        crewCell.detailTextLabel?.text = "\(crewCount) of \(model?.crewCapacity ?? 0)"
        crewCell.accessoryType = crewCount > 0 ? .DisclosureIndicator : .None
        crewCell.selectionStyle = crewCount > 0 ? .Default : .None

        livingSpacesLabel.text = String(model?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(model?.workspaceCount ?? 0)
        happinessLabel.text = percentFormatter.stringFromNumber(model?.crewHappiness ?? 0)
    }

}

extension VesselDetailTableViewController: ManagingObjectContext { }

extension VesselDetailTableViewController: MutableModelControlling { }

extension VesselDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        model?.name = textField.text
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
