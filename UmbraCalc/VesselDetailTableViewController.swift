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

class VesselDetailTableViewController: DetailTableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var partsCountLabel: UILabel!
    @IBOutlet weak var crewCountLabel: UILabel!
    @IBOutlet weak var crewCapacityLabel: UILabel!
    @IBOutlet weak var livingSpacesLabel: UILabel!
    @IBOutlet weak var workspacesLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!

    private let nameContext = ObserverContext(keyPath: "name")

    private var hasAppeared = false

    var vessel: Vessel? {
        didSet {
            // Prevent vessel from being faulted
            managedObjectContext = vessel?.managedObjectContext
            oldValue?.removeObserver(self, context: nameContext)
            vessel?.addObserver(self, context: nameContext)
            observerContextDidChange(nameContext)
        }
    }

    deinit {
        vessel?.removeObserver(self, context: nameContext)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editingDidChange()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        observerContextDidChange(nameContext)

        partsCountLabel.text = String(vessel?.partCount ?? 0)

        crewCountLabel.text = String(vessel?.crewCount ?? 0)

        crewCapacityLabel.text = String(vessel?.crewCapacity ?? 0)
        livingSpacesLabel.text = String(vessel?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(vessel?.workspaceCount ?? 0)
        happinessLabel.text = "\(Int(100 * (vessel?.crewHappiness ?? 0)))%"
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared && editing else { return }
        hasAppeared = true
        guard vessel?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    private func editingDidChange() {
        guard isViewLoaded() else { return }
        nameTextField.enabled = editing
    }

    override func contextDidChange(context: UnsafeMutablePointer<Void>) -> Bool {
        switch context {
        case &nameContext.context:
            guard isViewLoaded() && !ignoreContextChanges else { break }
            nameTextField.text = vessel?.name

        default:
            return false
        }
        return true
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        print(self.dynamicType, __FUNCTION__, identifier)
        switch identifier {
        case "browseCrew":
            guard let vessel = vessel, crewList = segue.destinationViewController as? CrewListTableViewController else { return }
            crewList.dataSource.fetchRequest.predicate = NSPredicate(format: "vessel = %@", vessel)
            if let name = vessel.name {
                crewList.navigationItem.title = "\(name) Crew"
            }

        case "editParts":
            guard let partList = segue.destinationViewController as? PartListTableViewController else { return }
            partList.vessel = vessel
            if let name = vessel?.name {
                partList.navigationItem.title = "\(name) Parts"
            }
            
        default:
            break
        }
    }

}

extension VesselDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        withIgnoredChanges {
            vessel?.name = textField.text
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
