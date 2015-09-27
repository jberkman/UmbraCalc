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

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var careerLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var starCountStepper: UIStepper!
    @IBOutlet weak var vesselLabel: UILabel!

    @IBOutlet weak var careerCell: UITableViewCell!
    @IBOutlet weak var vesselCell: UITableViewCell!

    private let nameContext = ObserverContext(keyPath: "name")
    private let careerContext = ObserverContext(keyPath: "career")
    private let starCountContext = ObserverContext(keyPath: "starCount")
    private let partContext = ObserverContext(keyPath: "part")
    private let vesselContext = ObserverContext(keyPath: "vessel")
    private let vesselNameContext = ObserverContext(keyPath: "name")

    private var ignoreContextChanges = false
    private var hasAppeared = false

    private var managedObjectContext: NSManagedObjectContext?
    var crew: Crew? {
        didSet {
            // Prevent crew from being faulted
            managedObjectContext = crew?.managedObjectContext
            forEachCrewContext {
                oldValue?.removeObserver(self, context: $0)
                crew?.addObserver(self, context: $0)
                contextDidChange($0)
            }
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if crew != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteCrewWithNotification:", name: willDeleteEntityNotification, object: crew!)
            }
        }
    }

    private var part: Part? {
        didSet {
            oldValue?.removeObserver(self, context: vesselContext)
            part?.addObserver(self, context: vesselContext)
            contextDidChange(vesselContext)
        }
    }

    private var vessel: Vessel? {
        didSet {
            oldValue?.removeObserver(self, context: vesselNameContext)
            vessel?.addObserver(self, context: vesselNameContext)
            contextDidChange(vesselNameContext)
        }
    }

    deinit {
        forEachCrewContext { crew?.removeObserver(self, context: $0) }
        part?.removeObserver(self, context: vesselContext)
        vessel?.removeObserver(self, context: vesselNameContext)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: nil)
    }

    private func forEachCrewContext(@noescape block: (ObserverContext) -> Void) {
        [ nameContext, careerContext, starCountContext, partContext ].forEach(block)
    }

    private func withIgnoredChanges(@noescape block: () -> Void) {
        let oldValue = ignoreContextChanges
        ignoreContextChanges = true
        block()
        ignoreContextChanges = oldValue
    }

    private func editingDidChange() {
        guard isViewLoaded() else { return }
        nameTextField.enabled = editing
    }

    private func contextDidChange(context: UnsafeMutablePointer<Void>) -> Bool {
        switch context {
        case &nameContext.context:
            guard isViewLoaded() && !ignoreContextChanges else { break }
            nameTextField.text = crew?.name

        case &careerContext.context:
            guard isViewLoaded() else { break }
            careerLabel.text = crew?.career ?? "Unemployed"

        case &starCountContext.context:
            guard isViewLoaded() else { break }
            guard let starCount = crew?.starCount else {
                starCountLabel.text = nil
                starCountStepper.enabled = false
                break
            }
            starCountLabel.text = starCount > 0 ? String(count: Int(starCount), repeatedValue: "⭐️") : "0 Stars"

            guard !ignoreContextChanges else { break }
            starCountStepper.value = Double(starCount)

        case &partContext.context:
            part = crew?.part

        case &vesselContext.context:
            vessel = part?.vessel

        case &vesselNameContext.context:
            guard isViewLoaded() else { break }
            vesselLabel.text = vessel?.name ?? "Unassigned"

        default:
            return false
        }
        return true
    }

    private func contextDidChange(context: ObserverContext) -> Bool {
        return contextDidChange(&context.context)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editingDidChange()
        [ nameContext, careerContext, starCountContext, vesselNameContext ].forEach {
            contextDidChange($0)
        }
        starCountStepper.addTarget(self, action: "stepperDidChange:", forControlEvents: .ValueChanged)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared && editing else { return }
        hasAppeared = true
        guard crew?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        editingDidChange()
        if !editing && nameTextField.isFirstResponder() {
            nameTextField.resignFirstResponder()
        }
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard !contextDidChange(context) else { return }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }

    @IBAction func stepperDidChange(sender: UIStepper) {
        withIgnoredChanges {
            crew?.starCount = Int16(sender.value)
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return editing
    }

    @objc private func willDeleteCrewWithNotification(notification: NSNotification) {
        guard let emptyDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController") else { return }
        showDetailViewController(emptyDetailViewController, sender: self)
    }

}

extension CrewDetailTableViewController {

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard tableView.cellForRowAtIndexPath(indexPath) == careerCell else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        [ Crew.engineerTitle, Crew.pilotTitle, Crew.scientistTitle ].forEach { career in
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

extension CrewDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        withIgnoredChanges {
            crew?.name = textField.text
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
