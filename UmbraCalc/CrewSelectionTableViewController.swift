//
//  CrewSelectionTableViewController.swift
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

class CrewSelectionTableViewController: UITableViewController {

    private(set) lazy var dataSource: SelectionDataSource<Crew, UITableViewCell> = SelectionDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.delegate = self
        dataSource.tableViewDelegate = self
        dataSource.fetchRequest.sortDescriptors = NamedEntity.sortDescriptors
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController != nil else { return }
        dataSource.reloadData()
    }

}

extension CrewSelectionTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        let crew = entity as! Crew
        dataSource.configureCell(cell, forNamedEntity: crew)
        dataSource.configureCell(cell, forCrew: crew)
    }

}

extension CrewSelectionTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}
