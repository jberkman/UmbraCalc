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

import JeSuis
import UIKit

class PartNodeListTableViewController: UITableViewController {

    private class PartNodeRow: Row {
        var partNode: PartNode
        init(partNode: PartNode, configureCell: (cell: UITableViewCell, partNode: PartNode) -> Void) {
            self.partNode = partNode
            super.init(reuseIdentifier: "reuseIdentifier") { cell, _ in
                configureCell(cell: cell, partNode: partNode)
            }
        }
    }

    @IBOutlet weak var cancelButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneButtonitem: UIBarButtonItem!

    private(set) var selectedPartNodes: Set<PartNode> = Set()

    var allowsMultipleSelection = false {
        didSet {
            guard isViewLoaded() else { return }
            tableView.reloadData()
        }
    }

    private var dataSource: StaticDataSource? {
        didSet {
            guard isViewLoaded() else { return }
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }

    var partNodes: [PartNode] = bundledPartNodes {
        didSet {
            guard isViewLoaded() else { return }
            updateDataSource()
        }
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()
        updateDataSource()
    }

    private func accessoryTypeForPartNode(partNode: PartNode) -> UITableViewCellAccessoryType {
        return allowsMultipleSelection ? selectedPartNodes.contains(partNode) ? .Checkmark : .None : .DetailButton
    }

    private func updateDataSource() {
        func livingSpaceFilter(partNode: PartNode) -> Bool {
            return partNode.livingSpaceCount > 0 || (partNode.crewCapacity > 0 && partNode.workspaceCount == 0)
        }

        func resourceFilter(outputResources: [String])(partNode: PartNode) -> Bool {
            return partNode.resourceConverters.values.contains {
                $0.outputResources.keys.contains { outputResources.contains($0) }
            }
        }

        func kolonizingRow(partNode: PartNode) -> PartNodeRow {
            return PartNodeRow(partNode: partNode) { [weak self] cell, partNode in
                cell.textLabel?.text = partNode.title
                cell.detailTextLabel?.text = partNode.kolonizingDetailText
                cell.accessoryType = self?.accessoryTypeForPartNode(partNode) ?? .None
            }
        }

        func resourceConvertingRow(partNode: PartNode) -> PartNodeRow {
            return PartNodeRow(partNode: partNode) { [weak self] cell, partNode in
                cell.textLabel?.text = partNode.title
                cell.detailTextLabel?.text = partNode.resourceConvertingDetailText
                cell.accessoryType = self?.accessoryTypeForPartNode(partNode) ?? .None
            }
        }

        dataSource = StaticDataSource(sections: [
            Section(rows: partNodes
                .filter(livingSpaceFilter)
                .map(kolonizingRow), headerTitle: "Crew and Living Spaces"),

            Section(rows: partNodes
                .filter { $0.workspaceCount > 0 }
                .map(kolonizingRow), headerTitle: "Workspaces"),

            Section(rows: partNodes
                .filter(resourceFilter(["Organics", "Supplies"]))
                .map(resourceConvertingRow), headerTitle: "Life Support"),

            Section(rows: partNodes
                .filter(resourceFilter(["ElectricCharge"]))
                .map(resourceConvertingRow), headerTitle: "Power"),

            Section(rows: partNodes
                .filter { !$0.resourceConverters.isEmpty && !resourceFilter(["Organics", "Supplies", "ElectricCharge"])(partNode: $0) }
                .map(resourceConvertingRow), headerTitle: "Resource Converters")

            ].filter { !$0.rows.isEmpty })
    }

    subscript (indexPath: NSIndexPath) -> PartNode {
        return (dataSource![indexPath] as! PartNodeRow).partNode
    }

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let partNode = self[indexPath]
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
                selectedPartNodes = Set([self[indexPath]])
            } else if let indexPath = sender as? NSIndexPath {
                selectedPartNodes = Set([self[indexPath]])
            }

        default:
            break
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard allowsMultipleSelection else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let partNode = self[indexPath]
        if selectedPartNodes.contains(partNode) == true {
            selectedPartNodes.remove(partNode)
        } else {
            selectedPartNodes.insert(partNode)
        }
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = accessoryTypeForPartNode(partNode)
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return !allowsMultipleSelection || identifier != "savePart"
    }

    @IBAction func enableMultipleSelection() {
        navigationItem.setRightBarButtonItem(doneButtonitem, animated: true)
        allowsMultipleSelection = true
    }

}
