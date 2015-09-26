//
//  StationListTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import CoreData
import UIKit

class StationListTableViewController: UITableViewController {

    private lazy var dataSource: FetchedDataSource<Station, UITableViewCell> = FetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configureCell = { (cell: UITableViewCell, station: Station) in
            cell.textLabel!.text = station.name
        }

        dataSource.tableView = tableView

        let fetchRequest = NSFetchRequest(entityName: "Station")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.fetchRequest = fetchRequest
    }

}

extension StationListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}
