//
//  PartListTableViewController.swift
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

class PartListTableViewController: UITableViewController {

    var dataSource: FetchedDataSource<Part, UITableViewCell> = FetchedDataSource()

    var vessel: Vessel? {
        didSet {
            dataSource.managedObjectContext = vessel?.managedObjectContext
            dataSource.fetchRequest.predicate = vessel != nil ? NSPredicate(format: "vessel = %@", vessel!) : nil
            guard isViewLoaded() else { return }
            dataSource.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        dataSource.configureCell = { (cell: UITableViewCell, part: Part) in
            cell.textLabel?.text = part.title
            cell.detailTextLabel?.text = "\(part.crew?.count ?? 0) Crew, \(Int(part.efficiency * 100))%"
        }
        dataSource.tableViewController = self
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
//        case "editPart":
//            guard let partDetail = segue.destinationViewController as? PartDetailTableViewController,
//                indexPath = sender is UITableViewCell ? tableView.indexPathForCell(sender as! UITableViewCell) : sender as? NSIndexPath else { return }
//            partDetail.part = dataSource.entityAtIndexPath(indexPath)

        case "insertPart":
            guard let partNodeListViewController = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? PartNodeListTableViewController else { return }
            partNodeListViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "partNodeListViewControllerDidCancel")
            partNodeListViewController.delegate = self

        default:
            break
        }
    }

}

extension PartListTableViewController {

    @objc private func partNodeListViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension PartListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}

extension PartListTableViewController: PartNodeListTableViewControllerDelegate {

    func partNodeListTableViewController(partNodeListTableViewController: PartNodeListTableViewController, didSelectPartNode partNode: PartNode) {
        dismissViewControllerAnimated(true) {
            guard let part = self.dataSource.insertPartWithPartName(partNode.name)?.withVessel(self.vessel),
                indexPath = self.dataSource.indexPathOfEntity(part) else { return }
            self.performSegueWithIdentifier("editPart", sender: indexPath)
        }
    }

}
