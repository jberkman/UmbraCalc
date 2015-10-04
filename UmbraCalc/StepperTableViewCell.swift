//
//  StepperTableViewCell.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-06.
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

class StepperTableViewCell: UITableViewCell {

    @IBOutlet weak var stepperTextLabel: UILabel!
    @IBOutlet weak var stepperDetailTextLabel: UILabel!

    private var minimumValue = 0.0
    private var maximumValue = 100.0

    @IBOutlet weak var stepper: UIStepper! {
        didSet {
            guard let stepper = stepper else { return }
            minimumValue = stepper.minimumValue
            maximumValue = stepper.maximumValue
        }
    }

    override var textLabel: UILabel? {
        return stepperTextLabel
    }

    override var detailTextLabel: UILabel? {
        return stepperDetailTextLabel
    }

    override func prepareForReuse() {
        stepper.removeTarget(nil, action: nil, forControlEvents: .ValueChanged)
        stepper.hidden = false
        stepper.minimumValue = minimumValue
        stepper.maximumValue = maximumValue
    }

}