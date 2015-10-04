//
//  PartDetailTableViewController.swift
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

class PartDetailTableViewController: UITableViewController {

    typealias Model = Part

    @IBOutlet weak var careerFactorLabel: UILabel!
    @IBOutlet weak var crewCell: UITableViewCell!
    @IBOutlet weak var crewEfficiencyLabel: UILabel!
    @IBOutlet weak var efficiencyLabel: UILabel!
    @IBOutlet weak var efficiencyPartsCount: UILabel!
    @IBOutlet weak var livingSpaceCountLabel: UILabel!
    @IBOutlet weak var partsEfficiencyLabel: UILabel!
    @IBOutlet weak var workspaceCountLabel: UILabel!

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    var managedObjectContext: NSManagedObjectContext?

    var model: Model? {
        didSet {
            managedObjectContext = model?.managedObjectContext
            updateView()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.showListSegueIdentifier:
            let segueNavigationController = segue.destinationViewController as! UINavigationController
            let crewSelection = segueNavigationController.viewControllers.first as! CrewSelectionTableViewController
            crewSelection.setManagingObjectContext(self)
            crewSelection.editing = true
            crewSelection.title = "Select Crew"
            crewSelection.navigationItem.leftBarButtonItem = crewSelection.addButtonItem
            crewSelection.navigationItem.rightBarButtonItem = crewSelection.doneButtonItem

            guard let part = model else { return }
            crewSelection.maximumSelectionCount = part.crewCapacity

            guard let crew = part.crew as? Set<Crew> else { return }
            crewSelection.selectedModels = crew

        default:
            break
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case Crew.showListSegueIdentifier:
            return model?.crewCapacity > 0

        default:
            return true
        }
    }

    @IBAction func saveCrew(segue: UIStoryboardSegue) {
        model?.crew = (segue.sourceViewController as! CrewSelectionTableViewController).selectedModels
        updateView()
    }

    private func updateView() {
        guard isViewLoaded() else { return }
        navigationItem.title = model?.title

        let count = model?.crew?.count ?? 0
        let capacity = model?.crewCapacity ?? 0

        crewCell.detailTextLabel?.text = capacity > 0 ? "\(count) of \(capacity)" : "Uncrewed"
        crewCell.accessoryType = capacity > 0 ? .DetailButton : .None

        livingSpaceCountLabel.text = String(model?.livingSpaceCount ?? 0)
        workspaceCountLabel.text = String(model?.workspaceCount ?? 0)
        careerFactorLabel.text = percentFormatter.stringFromNumber(model?.crewCareerFactor ?? 0)
        crewEfficiencyLabel.text = percentFormatter.stringFromNumber(model?.crewEfficiency ?? 0)
        efficiencyPartsCount.text = String(model?.efficiencyParts.count ?? 0)
        partsEfficiencyLabel.text = percentFormatter.stringFromNumber(model?.partsEfficiency ?? 0)
        efficiencyLabel.text = percentFormatter.stringFromNumber(model?.efficiency ?? 0)
    }

}

extension PartDetailTableViewController: ManagingObjectContext { }

extension PartDetailTableViewController: MutableModelControlling { }
