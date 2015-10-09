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

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var careerCell: UITableViewCell!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButtonItem: UIBarButtonItem!
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

        careerCell.detailTextLabel!.text = crew?.career
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

    @IBAction func stepperDidChange(sender: UIStepper) {
        crew?.starCount = Int16(sender.value)
        updateStars()
    }

//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        guard let identifier = segue.identifier else { return }
//        switch identifier {
//        case Crew.saveSegueIdentifier:
//            crew?.name = nameTextField.text
//
//        default:
//            break
//        }
//    }

    private func presentCareerSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        [ Crew.engineerTitle, Crew.pilotTitle, Crew.scientistTitle ].sort(<).forEach { career in
            alert.addAction(UIAlertAction(title: career, style: .Default) { _ in
                self.crew?.career = career
                self.careerCell.detailTextLabel!.text = career                })
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
