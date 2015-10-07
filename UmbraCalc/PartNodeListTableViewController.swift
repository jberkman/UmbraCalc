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

class PartNodeListTableViewController: UITableViewController {

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!

    private(set) var selectedPartNode: PartNode?

    lazy var partNodes: [PartNode] = bundledPartNodes

    static var bundledPartNodes: [PartNode] {
        return NSBundle.mainBundle().partNodes
            .filter { !$0.title.lowercaseString.containsString("legacy") }
            .sort {
                func awesomeness(partNode: PartNode) -> Int {
                    return partNode.crewCapacity + partNode.livingSpaceCount + partNode.workspaceCount
                }
                let (lhs, rhs) = (awesomeness($0) > 0, awesomeness($1) > 0)
                return (lhs && !rhs) || (lhs == rhs && $0.title < $1.title)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partNodes.count
    }

    func partNodeForRowAtIndexPath(indexPath: NSIndexPath) -> PartNode {
        return partNodes[indexPath.row]
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let partNode = partNodeForRowAtIndexPath(indexPath)
        cell.textLabel?.text = partNode.title
        var details: [String] = []
        if partNode.crewed {
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
            self.performSegueWithIdentifier(Part.saveSegueIdentifier, sender: indexPath)
            })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard segue.identifier == Part.saveSegueIdentifier else { return }
        switch segue.identifier! {
        case Part.saveSegueIdentifier:
            if let cell = sender as? UITableViewCell, indexPath = tableView.indexPathForCell(cell) {
                selectedPartNode = partNodeForRowAtIndexPath(indexPath)
            } else if let indexPath = sender as? NSIndexPath {
                selectedPartNode = partNodeForRowAtIndexPath(indexPath)
            }

        default:
            break
        }
    }

}
