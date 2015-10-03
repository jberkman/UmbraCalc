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

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var crewCapacityLabel: UILabel!
    @IBOutlet weak var livingSpaceCountLabel: UILabel!
    @IBOutlet weak var workspaceCountLabel: UILabel!
    @IBOutlet weak var crewCountLabel: UILabel!
    @IBOutlet weak var careerFactorLabel: UILabel!
    @IBOutlet weak var crewEfficiencyLabel: UILabel!
    @IBOutlet weak var efficiencyPartsCount: UILabel!
    @IBOutlet weak var partsEfficiencyLabel: UILabel!
    @IBOutlet weak var efficiencyLabel: UILabel!

    @IBOutlet weak var countStepper: UIStepper!

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    var managedObjectContext: NSManagedObjectContext?

    var model: Model? {
        didSet {
            managedObjectContext = model?.managedObjectContext
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        countStepper.addTarget(self, action: "countStepperDidChange:", forControlEvents: .ValueChanged)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
    }

    private func updateCountLabel() {
        let partCount = model?.count ?? 0
        countLabel.text = "\(partCount) Installed"
    }

    private func updateView() {
        guard isViewLoaded() else { return }
        navigationItem.title = model?.title

        updateCountLabel()

        countStepper.value = Double(model?.count ?? 0)

        let count = model?.crew?.count ?? 0
        crewCountLabel.text = String(count)
        countStepper.minimumValue = Double(count)

        crewCapacityLabel.text = String(model?.crewCapacity ?? 0)
        livingSpaceCountLabel.text = String(model?.livingSpaceCount ?? 0)
        workspaceCountLabel.text = String(model?.workspaceCount ?? 0)
        careerFactorLabel.text = percentFormatter.stringFromNumber(model?.crewCareerFactor ?? 0)
        crewEfficiencyLabel.text = percentFormatter.stringFromNumber(model?.crewEfficiency ?? 0)
        efficiencyPartsCount.text = String(model?.efficiencyParts?.count ?? 0)
        partsEfficiencyLabel.text = percentFormatter.stringFromNumber(model?.partsEfficiency ?? 0)
        efficiencyLabel.text = percentFormatter.stringFromNumber(model?.efficiency ?? 0)
    }

    @objc private func countStepperDidChange(stepper: UIStepper) {
        model?.count = Int16(stepper.value)
        updateCountLabel()
    }

}

extension PartDetailTableViewController: ManagingObjectContext { }

extension PartDetailTableViewController: MutableModelControlling { }
