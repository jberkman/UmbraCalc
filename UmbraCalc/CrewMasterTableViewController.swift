//
//  CrewMasterTableViewController.swift
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

class CrewMasterTableViewController: MasterTableViewController {

    private(set) lazy var dataSource: MasterDataSource<Crew, UITableViewCell> = MasterDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        dataSource.fetchRequest.sortDescriptors = NamedEntity.sortDescriptors
        dataSource.tableViewController = self
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.segueIdentifier,
            crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType() else { return }
        switch identifier {
        case .Insert:
            let scratchContext = ScratchContext(parent: dataSource)
            crewDetail.crew = scratchContext.insertCrew()!.withCareer(Crew.pilotTitle)
            crewDetail.navigationItem.title = "Add Crew"
            crewDetail.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "crewDetailViewControllerDidCancel")
            crewDetail.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "crewDetailViewControllerDidFinish")
            crewDetail.editing = true

        case .Edit, .View:
            guard let indexPath = tableView.indexPathForSegueSender(sender) else { return }
            let crew = dataSource.entityAtIndexPath(indexPath)
            crewDetail.crew = crew
            if case .Edit = identifier {
                crewDetail.navigationItem.rightBarButtonItem = crewDetail.editButtonItem()
            }
            crewDetail.editing = editing
            dataSource.selectedEntity = crew
        }
    }

    // Crew detail button handlers
    @objc private func crewDetailViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func crewDetailViewControllerDidFinish() {
        guard let crewDetail = (presentedViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController else { return }
        dismissViewControllerAnimated(true) {
            _ = try? crewDetail.crew?.saveToParentContext { (crew: Crew?) in
                guard self.splitViewController?.collapsed == false,
                    let crewToSelect = crew,
                    indexPath = self.dataSource.indexPathOfEntity(crewToSelect) else { return }

                self.performSegueWithIdentifier(SegueIdentifier.Edit.rawValue, sender: indexPath)
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
            }
        }
    }

}

extension CrewMasterTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        let crew = entity as! Crew
        dataSource.configureCell(cell, forNamedEntity: crew)
        dataSource.configureCell(cell, forCrew: crew)
        let accessoryType = currentAccessoryType
        cell.accessoryType = accessoryType
        cell.editingAccessoryType = accessoryType
    }

}

extension CrewMasterTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}

extension CrewMasterTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
