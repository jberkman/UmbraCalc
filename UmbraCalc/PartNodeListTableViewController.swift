//
//  PartNodeListTableViewController.swift
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

@objc protocol PartNodeListTableViewControllerDelegate: NSObjectProtocol {

    optional func partNodeListTableViewController(partNodeListTableViewController: PartNodeListTableViewController, didSelectPartNode partNode: PartNode)

}

class PartNodeListTableViewController: UITableViewController {

    weak var delegate: PartNodeListTableViewControllerDelegate?

    private lazy var partNodes: [PartNode] = NSBundle.mainBundle().partNodes
        .filter { !$0.title.lowercaseString.containsString("legacy") }
        .sort {
            func awesomeness(partNode: PartNode) -> Int {
                return partNode.crewCapacity + partNode.livingSpaceCount + partNode.workspaceCount
            }
            let (lhs, rhs) = (awesomeness($0), awesomeness($1))
            return lhs > rhs || lhs == rhs && $0.title < $1.title
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partNodes.count
    }

    private func partNodeForRowAtIndexPath(indexPath: NSIndexPath) -> PartNode {
        return partNodes[indexPath.row]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let partNode = partNodeForRowAtIndexPath(indexPath)
        cell.textLabel?.text = partNode.title
        var details = [String]()
        if partNode.crewCapacity > 0 {
            details.append("Crew Capacity: \(partNode.crewCapacity)")
        }
        if partNode.livingSpaceCount > 0 {
            details.append("Living Spaces: \(partNode.livingSpaceCount)")
        }
        if partNode.workspaceCount > 0 {
            details.append("Workspaces: \(partNode.workspaceCount)")
        }
        cell.detailTextLabel?.text = details.joinWithSeparator(" ")
        return cell
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let partNode = partNodeForRowAtIndexPath(indexPath)
        let alert = UIAlertController(title: partNode.title, message: partNode.descriptionText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Add", style: .Default) { _ in
            self.delegate?.partNodeListTableViewController?(self, didSelectPartNode: partNode)
            })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.partNodeListTableViewController?(self, didSelectPartNode: partNodeForRowAtIndexPath(indexPath))
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
