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

class CrewListTableViewController: UITableViewController {

    enum DetailType {
        case Vessel, Part
    }

    private class DataSource: FetchedDataSource<Crew, UITableViewCell> {

        var detailType = DetailType.Vessel

        override func configureCell(cell: UITableViewCell, forModel crew: Crew) {
            super.configureCell(cell, forModel: crew)
            cell.textLabel?.text = crew.displayName
            cell.detailTextLabel?.text = (detailType == .Vessel ? crew.part?.vessel?.displayName : crew.part?.title) ?? "Unassigned"
        }

    }

    private lazy var dataSource = DataSource()

    var predicate: NSPredicate? {
        get { return dataSource.fetchRequest.predicate }
        set { dataSource.fetchRequest.predicate = newValue }
    }

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }

    var detailType: DetailType {
        get { return dataSource.detailType }
        set { dataSource.detailType = newValue }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchRequest.sortDescriptors = [NamedEntity.nameSortDescriptor]
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        dataSource.reloadData()
    }

}
