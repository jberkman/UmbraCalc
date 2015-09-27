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

    private lazy var dataSource: FetchedDataSource<Station, UITableViewCell> = FetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configureCell = { (cell: UITableViewCell, station: Station) in
            cell.textLabel!.text = station.name
        }

        dataSource.tableViewController = self

        let fetchRequest = NSFetchRequest(entityName: "Station")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.fetchRequest = fetchRequest
    }

    override func showDetailViewControllerForEntityAtIndexPath(indexPath: NSIndexPath) {
        performSegueWithIdentifier("editStation", sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
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
