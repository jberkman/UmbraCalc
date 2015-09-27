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
