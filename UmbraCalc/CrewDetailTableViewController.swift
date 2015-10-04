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

    typealias Model = Crew

    @IBOutlet weak var assignmentCell: UITableViewCell!
    @IBOutlet weak var careerCell: UITableViewCell!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var starCountStepper: UIStepper!
    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!

    private var hasAppeared = false

    var managedObjectContext: NSManagedObjectContext?

    var model: Model? {
        didSet {
            // Prevent crew from being faulted
            managedObjectContext = model?.managedObjectContext
            updateView()
        }
    }

    private func updateStars() {
        guard let starString = model?.starString else {
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

        nameTextField.text = model?.name

        updateStars()
        starCountStepper.value = Double(model?.starCount ?? 0)

        careerCell.textLabel!.text = model?.career

        if let partName = model?.part?.title, vesselName = model?.part?.vessel?.displayName {
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
        guard model?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case Vessel.showSegueIdentifier:
            return model?.part?.vessel != nil
        default:
            return true
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.saveSegueIdentifier:
            model?.name = nameTextField.text

        case Vessel.showListSegueIdentifier:
            let destinationNavigationController = segue.destinationViewController as! UINavigationController
            let vesselList = destinationNavigationController.viewControllers.first as! VesselListTableViewController
            vesselList.managedObjectContext = managedObjectContext

        case Vessel.showSegueIdentifier:
            let vesselDetail: VesselDetailTableViewController = segue.destinationViewController as! VesselDetailTableViewController
            vesselDetail.model = model?.part?.vessel

        default:
            break
        }
    }

    @IBAction func stepperDidChange(sender: UIStepper) {
        model?.starCount = Int16(sender.value)
        updateStars()
    }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        model?.part = (segue.sourceViewController as! PartSelectionTableViewController).selectedModel
        updateView()
    }

    @IBAction func cancelVessel(segue: UIStoryboardSegue) { }

    private func presentCareerSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        [ Crew.engineerTitle, Crew.pilotTitle, Crew.scientistTitle ].sort(<).forEach { career in
            alert.addAction(UIAlertAction(title: career, style: .Default) { _ in
                self.model?.career = career
                })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.popoverPresentationController?.sourceView = careerCell
        alert.popoverPresentationController?.sourceRect = careerCell.bounds
        alert.popoverPresentationController?.permittedArrowDirections = [ .Down, .Up ]
        presentViewController(alert, animated: true, completion: nil)
    }

}

extension CrewDetailTableViewController: ManagingObjectContext { }

extension CrewDetailTableViewController: MutableModelControlling { }

extension CrewDetailTableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView.cellForRowAtIndexPath(indexPath) == careerCell else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        presentCareerSheet()
    }

}

extension CrewDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        model?.name = textField.text
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
