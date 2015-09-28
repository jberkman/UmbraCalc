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

import UIKit

class PartDetailTableViewController: DetailTableViewController {

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

    private let countContext = ObserverContext(keyPath: "count")
    private let crewContext = ObserverContext(keyPath: "crew")

    func forEachContext(@noescape body: (ObserverContext) -> Void) {
        [ countContext, crewContext ].forEach(body)
    }

    var part: Part? {
        didSet {
            managedObjectContext = part?.managedObjectContext
            navigationItem.title = part?.title
            forEachContext {
                oldValue?.removeObserver(self, context: $0)
                part?.addObserver(self, context: $0)
                observerContextDidChange($0)
            }
        }
    }

    deinit {
        forEachContext { part?.removeObserver(self, context: $0) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        forEachContext { observerContextDidChange($0) }
        countStepper.addTarget(self, action: "countStepperDidChange:", forControlEvents: .ValueChanged)
    }

    override func contextDidChange(context: UnsafeMutablePointer<Void>) -> Bool {
        switch context {
        case &countContext.context:
            guard isViewLoaded() else { return true }
            let partCount = part?.count ?? 0
            if !ignoreContextChanges {
                countStepper.value = Double(partCount)
            }
            countLabel.text = "\(partCount) Installed"

        case &crewContext.context:
            guard isViewLoaded() else { return true }
            crewCountLabel.text = String(part?.crew?.count ?? 0)

        default:
            return false
        }

        crewCapacityLabel.text = String(part?.crewCapacity ?? 0)
        livingSpaceCountLabel.text = String(part?.livingSpaceCount ?? 0)
        workspaceCountLabel.text = String(part?.workspaceCount ?? 0)
        careerFactorLabel.text = "\(Int(100 * (part?.crewCareerFactor ?? 0)))%"
        crewEfficiencyLabel.text = "\(Int(100 * (part?.crewEfficiency ?? 0)))%"
        efficiencyPartsCount.text = String(part?.efficiencyParts?.count ?? 0)
        partsEfficiencyLabel.text = "\(Int(100 * (part?.partsEfficiency ?? 0)))%"
        efficiencyLabel.text = "\(Int(100 * (part?.efficiency ?? 0)))%"

        return true
    }

    @objc private func countStepperDidChange(stepper: UIStepper) {
        withIgnoredChanges {
            part?.count = Int16(stepper.value)
        }
    }

}
