//
//  StationMasterTableViewController.swift
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

class StationMasterTableViewController: MasterTableViewController {

    private lazy var dataSource: MasterDataSource<Station, UITableViewCell> = MasterDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        dataSource.fetchRequest.sortDescriptors = NamedEntity.sortDescriptors
        dataSource.tableViewController = self
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.segueIdentifier,
            vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType() else { return }

        switch identifier {
        case .Insert:
            let scratchContext = ScratchContext(parent: dataSource)
            vesselDetail.vessel = scratchContext.insertStation()
            vesselDetail.navigationItem.title = "Add Station"
            vesselDetail.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "vesselDetailViewControllerDidCancel")
            vesselDetail.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "vesselDetailViewControllerDidFinish")
            vesselDetail.editing = true

        case .Edit, .View:
            guard let indexPath = tableView.indexPathForSegueSender(sender) else { return }
            let vessel = dataSource.entityAtIndexPath(indexPath)
            vesselDetail.vessel = vessel
            vesselDetail.navigationItem.title = "Station Details"
            vesselDetail.editing = true
            dataSource.selectedEntity = vessel

        }
    }

    // Station detail button handlers
    @objc private func vesselDetailViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func vesselDetailViewControllerDidFinish() {
        guard let vesselDetail = (presentedViewController as? UINavigationController)?.viewControllers.first as? VesselDetailTableViewController else { return }
        dismissViewControllerAnimated(true) {
            _ = try? vesselDetail.vessel?.saveToParentContext { (station: Station?) in
                guard self.splitViewController?.collapsed == false,
                    let stationToSelect = station,
                    indexPath = self.dataSource.indexPathOfEntity(stationToSelect) else { return }

                self.performSegueWithIdentifier(SegueIdentifier.Edit.rawValue, sender: indexPath)
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        }
    }

}

extension StationMasterTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        dataSource.configureCell(cell, forNamedEntity: entity as! Station)
    }

}

extension StationMasterTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}

extension StationMasterTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
