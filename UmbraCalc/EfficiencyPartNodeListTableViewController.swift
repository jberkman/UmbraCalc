//
//  EfficiencyPartNodeListTableViewController.swift
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

class EfficiencyPartNodeListTableViewController: PartNodeListTableViewController {

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    var part: Part? {
        didSet {
            partNodes = PartNodeListTableViewController.bundledPartNodes.filter {
                self.part?.efficiencyParts[$0.name] != nil
            }
            guard isViewLoaded() else { return }
            tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let partNode = partNodeForRowAtIndexPath(indexPath)
        cell.textLabel?.text = partNode.title
        guard let vesselEfficiencyParts = part?.vessel?.efficiencyParts,
            rate = part?.efficiencyParts[partNode.name],
            rateString = percentFormatter.stringFromNumber(rate) else { return cell }
        let count = vesselEfficiencyParts.map { $0.partName == partNode.name ? $0.count : 0 }.reduce(0, combine: +)
        cell.detailTextLabel?.text = "\(count) X \(rateString)"
        return cell
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "If this part supports efficiency parts, adding them to this station or kolony will improve this part's efficiency and allow it to be used uncrewed."
    }
    
}
