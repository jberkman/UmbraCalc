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

    private lazy var dataSource: FetchedDataSource<Kolony, UITableViewCell> = FetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableViewController = self
        dataSource.configureCell = { [weak self] (cell: UITableViewCell, kolony: Kolony) in
            self?.dataSource.configureCell(cell, namedEntity: kolony)
        }
        dataSource.reloadData()
    }

    override func showDetailViewControllerForEntityAtIndexPath(indexPath: NSIndexPath) {
//        performSegueWithIdentifier("editKolony", sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
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
