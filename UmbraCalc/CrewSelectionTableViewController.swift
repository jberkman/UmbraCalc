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

    typealias Model = Crew

    private class DataSource: SelectionDataSource<Crew, UITableViewCell> {

        override func configureCell(cell: UITableViewCell, forModel crew: Crew) {
            configureCell(cell, forNamedEntity: crew)
            configureCell(cell, forCrew: crew)
        }

    }

    private(set) lazy var dataSource: SelectionDataSource<Crew, UITableViewCell> = DataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableViewDelegate = self
        dataSource.fetchRequest.sortDescriptors = [NamedEntity.nameSortDescriptor]
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController != nil else { return }
        dataSource.reloadData()
    }

}

extension CrewSelectionTableViewController: MutableModelMultipleSelecting {

    var selectedModels: Set<Model> {
        get { return dataSource.selectedModels }
        set { dataSource.selectedModels = newValue }
    }

    var maximumSelectionCount: Int {
        get { return dataSource.maximumSelectionCount }
        set { dataSource.maximumSelectionCount = newValue }
    }

}

extension CrewSelectionTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}
