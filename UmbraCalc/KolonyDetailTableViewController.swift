//
//  KolonyDetailTableViewController.swift
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

class KolonyDetailTableViewController: UITableViewController {

    typealias Model = Kolony

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var baseCountLabel: UILabel!
    @IBOutlet weak var crewCell: UITableViewCell!
    @IBOutlet weak var livingSpacesLabel: UILabel!
    @IBOutlet weak var workspacesLabel: UILabel!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    private var hasAppeared = false

    var managedObjectContext: NSManagedObjectContext?

    var model: Model? {
        didSet {
            // Prevent vessel from being faulted
            managedObjectContext = model?.managedObjectContext
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
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Crew.showListSegueIdentifier:
            let crewSelection = segue.destinationViewController as! CrewSelectionTableViewController
            crewSelection.setManagingObjectContext(self)

            guard let kolony = model else { return }
            crewSelection.predicate = NSPredicate(format: "part.vessel.kolony = %@", kolony)
            crewSelection.navigationItem.title = "\(kolony.displayName) Crew"

        case Model.saveSegueIdentifier:
            model?.name = nameTextField.text

        case Vessel.showListSegueIdentifier:
            let vesselList = segue.destinationViewController as! VesselListTableViewController
            vesselList.kolony = model

        default:
            break
        }
    }

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = model?.name

        baseCountLabel.text = String(model?.bases?.count ?? 0)

        let crewCount = model?.crewCount ?? 0
        crewCell.detailTextLabel?.text = "\(crewCount) of \(model?.crewCapacity ?? 0)"
        crewCell.accessoryType = crewCount > 0 ? .DisclosureIndicator : .None
        crewCell.selectionStyle = crewCount > 0 ? .Default : .None

        livingSpacesLabel.text = String(model?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(model?.workspaceCount ?? 0)
    }

}

extension KolonyDetailTableViewController: ManagingObjectContext { }

extension KolonyDetailTableViewController: MutableModelControlling { }

extension KolonyDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        model?.name = textField.text
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
