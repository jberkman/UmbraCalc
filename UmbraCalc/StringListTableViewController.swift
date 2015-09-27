//
//  StringListTableViewController.swift
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

import UIKit

@objc protocol StringListTableViewControllerDelegate: NSObjectProtocol {
    optional func stringListTableViewController(stringListTableViewController: StringListTableViewController, didSelectString string: String)
}

class StringListTableViewController: UITableViewController {

    var strings: [String] = [] {
        didSet  {
            guard isViewLoaded() else { return }
            tableView.reloadData()
        }
    }

    var selectedValue: String = "" {
        didSet {
            updateCheckmarks()
        }
    }

    weak var delegate: StringListTableViewControllerDelegate?

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = strings[indexPath.row]
        cell.accessoryType = selectedValue == strings[indexPath.row] ? .Checkmark : .None
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedValue = strings[indexPath.row]
        delegate?.stringListTableViewController?(self, didSelectString: selectedValue)
    }

    private func updateCheckmarks() {
        tableView.indexPathsForVisibleRows?.forEach {
            tableView.cellForRowAtIndexPath($0)?.accessoryType = strings[$0.row] == selectedValue ?.Checkmark : .None
        }
    }

}
