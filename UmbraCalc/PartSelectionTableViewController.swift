//
//  PartSelectionTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-03.
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

class PartSelectionTableViewController: UITableViewController {

    typealias Model = Part

    var selectedModel: Model?

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    private var parts: [Model] = [] {
        didSet {
            guard isViewLoaded() else { return }
            tableView.reloadData()
        }
    }

    var vessel: Vessel? {
        didSet {
            parts = (vessel?.parts as? Set<Part>)?.filter { $0.crew?.count < $0.crewCapacity } ?? []
        }
    }

    func partForRowAtIndexPath(indexPath: NSIndexPath) -> Part {
        return parts[indexPath.row]
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let part = partForRowAtIndexPath(indexPath)

        cell.textLabel?.text = part.title
        let efficiency = "Efficiency: \(percentFormatter.stringFromNumber(part.efficiency)!)"
        cell.detailTextLabel?.text = "Crew: \(part.crew?.count ?? 0) of \(part.crewCapacity) \(efficiency)"

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Part.saveSegueIdentifier:
            selectedModel = partForRowAtIndexPath(tableView.indexPathForCell(sender as! UITableViewCell)!)

        default:
            break
        }
    }

}
