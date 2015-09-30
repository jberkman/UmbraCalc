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

class CrewDetailTableViewController: UITableViewController, ManagingObjectContext {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var careerLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var starCountStepper: UIStepper!
    @IBOutlet weak var assignmentLabel: UILabel!

    @IBOutlet weak var careerCell: UITableViewCell!

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
        guard let starCount = crew?.starCount else {
            starCountLabel.text = nil
            return
        }
        starCountLabel.text = starCount > 0 ? String(count: Int(starCount), repeatedValue: "⭐️") : "0 Stars"
    }

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = crew?.name

        updateStars()
        starCountStepper.value = Double(crew?.starCount ?? 0)

        careerLabel.text = crew?.career ?? "Unemployed"

        if let partName = crew?.part?.title, vesselName = crew?.part?.vessel?.name {
            assignmentLabel.text = "\(vesselName) - \(partName)"
        } else {
            assignmentLabel.text = "Unassigned"
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard "save" == segue.identifier else { return }
        crew?.name = nameTextField.text
    }

    @IBAction func stepperDidChange(sender: UIStepper) {
        crew?.starCount = Int16(sender.value)

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
