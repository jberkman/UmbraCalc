//
//  CrewDetailTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
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

class CrewDetailTableViewController: UITableViewController {

    @IBOutlet weak var assignmentCell: UITableViewCell!
    @IBOutlet weak var careerCell: UITableViewCell!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var starCountStepper: UIStepper!

    private var hasAppeared = false

    var managedObjectContext: NSManagedObjectContext?

    var crew: Crew? {
        didSet {
            // Prevent crew from being faulted
            managedObjectContext = crew?.managedObjectContext
            updateView()
        }
    }

    private func updateStars() {
        guard let starString = crew?.starString else {
            starCountLabel.text = nil
            return
        }
        guard !starString.isEmpty else {
            starCountLabel.text = "0 Stars"
            return
        }
        starCountLabel.text = starString
    }

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = crew?.name

        updateStars()
        starCountStepper.value = Double(crew?.starCount ?? 0)

        careerCell.textLabel!.text = crew?.career

        if let partName = crew?.part?.title, vesselName = crew?.part?.vessel?.displayName {
            assignmentCell.accessoryType = .DetailDisclosureButton
            assignmentCell.selectionStyle = .Default
            assignmentCell.detailTextLabel!.text = "\(vesselName) - \(partName)"
        } else {
            if let managedObjectContext = self.managedObjectContext where Vessel.existsInContext(managedObjectContext) {
                assignmentCell.accessoryType = .DetailButton
            } else {
                assignmentCell.accessoryType = .None
            }
            assignmentCell.selectionStyle = .None
            assignmentCell.detailTextLabel!.text = "Unassigned"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        starCountStepper.addTarget(self, action: "stepperDidChange:", forControlEvents: .ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        guard crew?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case Vessel.showSegueIdentifier:
            return crew?.part?.vessel != nil
        default:
            return true
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Vessel.showListSegueIdentifier:
            let vesselList = segue.destinationViewController as! VesselListTableViewController
            vesselList.managedObjectContext = managedObjectContext

        case Vessel.showSegueIdentifier:
            let vesselDetail: VesselDetailTableViewController = segue.destinationViewController as! VesselDetailTableViewController
            vesselDetail.vessel = crew?.part?.vessel

        default:
            break
        }
    }

    @IBAction func stepperDidChange(sender: UIStepper) {
        crew?.starCount = Int16(sender.value)
        updateStars()
    }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        crew?.part = (segue.sourceViewController as! PartSelectionTableViewController).selectedPart
        updateView()
    }

    private func presentCareerSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        [ Crew.engineerTitle, Crew.pilotTitle, Crew.scientistTitle ].sort(<).forEach { career in
            alert.addAction(UIAlertAction(title: career, style: .Default) { _ in
                self.crew?.career = career
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = careerCell
        alert.popoverPresentationController?.sourceRect = careerCell.bounds
        alert.popoverPresentationController?.permittedArrowDirections = [ .Down, .Up ]
        presentViewController(alert, animated: true, completion: nil)
    }

}

extension CrewDetailTableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView.cellForRowAtIndexPath(indexPath) == careerCell else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        presentCareerSheet()
    }

}

extension CrewDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        crew?.name = textField.text
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
