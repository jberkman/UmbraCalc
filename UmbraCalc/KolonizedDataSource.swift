//
//  KolonizedDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-09.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import Foundation
import UIKit

@objc
protocol KolonizedDataSourceDelegate: NSObjectProtocol {
    optional func tableView(tableView: UITableView, stepperAccessory: UIStepper, valueChangedForRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: UITableView, switchAccessory: UISwitch, valueChangedForRowAtIndexPath indexPath: NSIndexPath)
}

class KolonizedDataSource: ScopedDataSource {

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    private func textLabelForResourceConverter(resourceConverter: ResourceConverter) -> String? {
        guard resourceConverter.part?.crewCapacity == 0 else { return resourceConverter.name }
        let capacity = resourceConverter.part?.count ?? 0
        return "\(resourceConverter.displayName) (\(resourceConverter.activeCount) of \(capacity))"
    }

    private func configureCell(cell: UITableViewCell, forBase base: Base) {
        cell.textLabel?.text = base.displayName
        cell.detailTextLabel?.text = "\(base.crewCount) of \(base.crewCapacity) Crew, \(percentFormatter.stringFromNumber(base.happiness)!) Happiness"
        cell.accessoryType = .DetailButton
    }

    private func configureCell(cell: UITableViewCell, forCrew crew: Crew) {
        cell.textLabel?.text = crew.crewDisplayName
        cell.detailTextLabel?.text = crew.career
        cell.accessoryType = .DisclosureIndicator
    }

    @objc private func stepperDidChangeValue(sender: UIStepper) {
        guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
        (tableView?.delegate as? KolonizedDataSourceDelegate)?.tableView?(tableView, stepperAccessory: sender, valueChangedForRowAtIndexPath: indexPath)
    }

    @objc private func switchDidChangeValue(sender: UISwitch) {
        guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
        (tableView?.delegate as? KolonizedDataSourceDelegate)?.tableView?(tableView, switchAccessory: sender, valueChangedForRowAtIndexPath: indexPath)
    }

    private func configureCell(cell: UITableViewCell, forResourceConverter resourceConverter: ResourceConverter) {
        cell.textLabel?.text = textLabelForResourceConverter(resourceConverter)

        let inputs = resourceConverter.inputResources.keys.sort().joinWithSeparator(" + ")
        let outputs = resourceConverter.outputResources.keys.sort().joinWithSeparator(" + ")
        cell.detailTextLabel?.text = "\(inputs) -> \(outputs)"

        if resourceConverter.part?.crewed == true {
            if cell.accessoryView == nil {
                let toggle = UISwitch()
                toggle.addTarget(self, action: "switchDidChangeValue:", forControlEvents: .ValueChanged)
                cell.accessoryView = toggle
            }
            (cell.accessoryView as! UISwitch).on = resourceConverter.activeCount > 0
        } else {
            if cell.accessoryView == nil {
                let stepper = UIStepper()
                stepper.addTarget(self, action: "stepperDidChangeValue:", forControlEvents: .ValueChanged)
                cell.accessoryView = stepper
            }
            let stepper = cell.accessoryView as! UIStepper
            stepper.value = Double(resourceConverter.activeCount)
            stepper.maximumValue = Double(resourceConverter.part?.count ?? 0)
        }
    }

    private func configureCell(cell: UITableViewCell, forPart part: Part) {
        cell.textLabel?.text = part.displayName
        cell.detailTextLabel?.text = part.displaySummary

        guard !part.crewed else {
            cell.accessoryType = .DisclosureIndicator
            return
        }

        guard cell.accessoryView == nil else { return }
        let stepper = UIStepper()
        stepper.value = Double(part.count)
        stepper.addTarget(self, action: "stepperDidChangeValue:", forControlEvents: .ValueChanged)
        cell.accessoryView = stepper
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = modelAtIndexPath(indexPath)
        let reuseIdentifier: String
        if model is Base {
            reuseIdentifier = "baseCell"
        } else if let part = model as? Part {
            reuseIdentifier = (part.crewed ? "" : "un") + "crewedPartCell"
        } else if let resourceConverter = model as? ResourceConverter {
            reuseIdentifier = (resourceConverter.part?.crewed == true ? "" : "un") + "crewedResourceConverterCell"
        } else {
            reuseIdentifier = "crewCell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        configureCell(cell, forModel: model)
        cell.indentationWidth = 15
        return cell
    }

    override func configureCell(cell: ScopedDataSource.Cell, forModel model: Model) {
        if let base = model as? Base {
            configureCell(cell, forBase: base)
        } else if let part = model as? Part {
            configureCell(cell, forPart: part)
        } else if let resourceConverter = model as? ResourceConverter {
            configureCell(cell, forResourceConverter: resourceConverter)
        } else {
            configureCell(cell, forCrew: model as! Crew)
        }
    }

}
