//
//  VesselDetailTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import CoreData
import UIKit

class VesselDetailTableViewController: DetailTableViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var partsCountLabel: UILabel!
    @IBOutlet weak var crewCountLabel: UILabel!

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

    private func withIgnoredChanges(@noescape block: () -> Void) {
        let oldValue = ignoreContextChanges
        ignoreContextChanges = true
        block()
        ignoreContextChanges = oldValue
    }

    deinit {
        vessel?.removeObserver(self, context: nameContext)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        editingDidChange()
        observerContextDidChange(nameContext)
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
