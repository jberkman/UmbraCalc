//
//  StationListTableViewController.swift
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

import CoreData
import UIKit

class StationListTableViewController: MasterTableViewController {

    private lazy var dataSource: MasterDataSource<Station, UITableViewCell> = MasterDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.masterDelegate = self
        dataSource.fetchRequest.sortDescriptors = dataSource.nameSortDescriptors
        dataSource.tableViewController = self
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        print(self.dynamicType, __FUNCTION__, identifier)
        switch identifier {
            case "insertStation":
                guard let vesselDetail = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? VesselDetailTableViewController else { return }

                let scratchContext = ScratchContext(parent: dataSource)
                vesselDetail.vessel = scratchContext.insertStation()
                vesselDetail.navigationItem.title = "Add Station"
                vesselDetail.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "vesselDetailViewControllerDidCancel")
                vesselDetail.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "vesselDetailViewControllerDidFinish")
                vesselDetail.editing = true

            case "editStation", "viewStation":
                guard let vesselDetail = segue.destinationViewController as? VesselDetailTableViewController ??
                    (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? VesselDetailTableViewController,
                    indexPath = sender is UITableViewCell ? tableView.indexPathForCell(sender as! UITableViewCell) : sender as? NSIndexPath else { return }

                let vessel = dataSource.entityAtIndexPath(indexPath)
                vesselDetail.vessel = vessel
                vesselDetail.navigationItem.title = "Station Details"
                if identifier == "editStation" {
                    vesselDetail.navigationItem.rightBarButtonItem = vesselDetail.editButtonItem()
                }
                dataSource.selectedEntity = vessel

        default:
            break

        }
    }

    override func showDetailViewControllerForEntityAtIndexPath(indexPath: NSIndexPath) {
        performSegueWithIdentifier("editStation", sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    // Station detail button handlers
    @objc private func vesselDetailViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func vesselDetailViewControllerDidFinish() {
        guard let vesselDetail = (presentedViewController as? UINavigationController)?.viewControllers.first as? VesselDetailTableViewController else { return }
        dismissViewControllerAnimated(true) {
            guard let vessel = vesselDetail.vessel else { return }
            try! vessel.managedObjectContext!.obtainPermanentIDsForObjects([vessel])
            let objectID = vessel.objectID
            try! vessel.managedObjectContext!.save()

            guard self.splitViewController?.collapsed == false,
                let vesselToSelect = self.dataSource.managedObjectContext?.objectWithID(objectID) as? Station,
                indexPath = self.dataSource.indexPathOfEntity(vesselToSelect) else { return }
            self.showDetailViewControllerForEntityAtIndexPath(indexPath)
        }
    }

}

extension StationListTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        dataSource.configureCell(cell, forNamedEntity: entity as! Station)
    }

}

extension StationListTableViewController: MasterDataSourceDelegate {

    func masterDataSource<Entity, Cell>(masterDataSource: MasterDataSource<Entity, Cell>, showDetailViewControllerForRowAtIndexPath indexPath: NSIndexPath) {
        showDetailViewControllerForEntityAtIndexPath(indexPath)
    }

}

extension StationListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}

extension StationListTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
