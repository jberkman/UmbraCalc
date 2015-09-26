//
//  CrewListTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import CoreData
import UIKit

class CrewListTableViewController: UITableViewController {

    private lazy var dataSource: FetchedDataSource<Crew, UITableViewCell> = FetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configureCell = { (cell: UITableViewCell, crew: Crew) in
            cell.textLabel?.text = crew.name
            guard let career = crew.career else {
                cell.detailTextLabel?.text = "\(crew.starCount) Stars"
                return
            }
            cell.detailTextLabel?.text = "\(crew.starCount)-Star \(career)"
        }

        dataSource.tableView = tableView

        let fetchRequest = NSFetchRequest(entityName: "Crew")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.fetchRequest = fetchRequest
    }

}

extension CrewListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}
