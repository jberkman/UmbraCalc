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

    var dataSource: ManagedDataSource<Part, UITableViewCell> = ManagedDataSource()
    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")
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
        dataSource.delegate = self
        dataSource.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        dataSource.tableView = tableView
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.segueIdentifier else { return }
        switch identifier {
        case .Edit, .View:
            guard let partDetail = segue.destinationViewController as? PartDetailTableViewController,
                indexPath = tableView.indexPathForSegueSender(sender) else { return }
            partDetail.part = dataSource.entityAtIndexPath(indexPath)

        case .Insert:
            guard let partNodeListViewController: PartNodeListTableViewController = segue.destinationViewControllerWithType() else { return }
            partNodeListViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "partNodeListViewControllerDidCancel")
            partNodeListViewController.delegate = self
        }
    }

}

extension PartListTableViewController {

    @objc private func partNodeListViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension PartListTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        let part = entity as! Part
        cell.textLabel?.text = part.title
        cell.detailTextLabel?.text = "Installed: \(part.count) Crew: \(part.crew?.count ?? 0) Efficiency: \(percentFormatter.stringFromNumber(part.efficiency)!)"
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
            guard let part = (self.vessel?.parts as? Set<Part>)?.lazy
                .filter({ $0.partName == partNode.name })
                .first?.withAdditionalCount(1) ??
                self.dataSource.insertPartWithPartName(partNode.name)?.withVessel(self.vessel) else { return }
            self.dataSource.managedObjectContext?.processPendingChanges()
            guard let indexPath = self.dataSource.indexPathOfEntity(part) else { return }
            self.performSegueWithIdentifier(SegueIdentifier.Edit.rawValue, sender: indexPath)
        }
    }

}
