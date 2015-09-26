//
//  KolonyListTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import CoreData
import UIKit

class KolonyListTableViewController: UITableViewController {

    private lazy var dataSource: FetchedDataSource<Kolony, UITableViewCell> = FetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configureCell = { (cell: UITableViewCell, kolony: Kolony) in
            cell.textLabel!.text = kolony.name
        }

        dataSource.tableView = tableView

        let fetchRequest = NSFetchRequest(entityName: "Kolony")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.fetchRequest = fetchRequest
    }

}

extension KolonyListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}
