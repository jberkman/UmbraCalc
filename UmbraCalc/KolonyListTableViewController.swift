//
//  KolonyListTableViewController.swift
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

class KolonyListTableViewController: MasterTableViewController {

    private lazy var dataSource: MasterDataSource<Kolony, UITableViewCell> = MasterDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.masterDelegate = self
        dataSource.fetchRequest.sortDescriptors = dataSource.nameSortDescriptors
        dataSource.tableViewController = self
        dataSource.reloadData()
    }

    override func showDetailViewControllerForEntityAtIndexPath(indexPath: NSIndexPath) {
        //        performSegueWithIdentifier("editKolony", sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

}

extension KolonyListTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        dataSource.configureCell(cell, forNamedEntity: entity as! Kolony)
    }

}

extension KolonyListTableViewController: MasterDataSourceDelegate {

    func masterDataSource<Entity, Cell>(masterDataSource: MasterDataSource<Entity, Cell>, showDetailViewControllerForRowAtIndexPath indexPath: NSIndexPath) {
        showDetailViewControllerForEntityAtIndexPath(indexPath)
    }

}

extension KolonyListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}

extension KolonyListTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
