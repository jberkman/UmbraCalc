//
//  KolonyMasterTableViewController.swift
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

class KolonyMasterTableViewController: MasterTableViewController {

    private lazy var dataSource: MasterDataSource<Kolony, UITableViewCell> = MasterDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        dataSource.fetchRequest.sortDescriptors = NamedEntity.sortDescriptors
        dataSource.tableViewController = self
        dataSource.reloadData()
    }

}

extension KolonyMasterTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        dataSource.configureCell(cell, forNamedEntity: entity as! Kolony)
    }

}

extension KolonyMasterTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}

extension KolonyMasterTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
