//
//  PartListTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
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

class PartListTableViewController: UITableViewController {

    typealias Model = Part

    private class DataSource: FetchedDataSource<Part, UITableViewCell> {

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

        override func configureCell(cell: UITableViewCell, forModel part: Part) {
            cell.textLabel?.text = part.title
            cell.detailTextLabel?.text = "Installed: \(part.count) Crew: \(part.crew?.count ?? 0) Efficiency: \(percentFormatter.stringFromNumber(part.efficiency)!)"
        }

    }

    private(set) var selectedModel: Model?

    private(set) var dataSource: FetchedDataSource<Part, UITableViewCell> = DataSource()

    var vessel: Vessel? {
        didSet {
            managedObjectContext = vessel?.managedObjectContext
            predicate = vessel == nil ? nil : NSPredicate(format: "vessel = %@", vessel!)
            guard isViewLoaded() else { return }
            dataSource.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        dataSource.reloadData()
    }

}

extension PartListTableViewController: MutableManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }
    
}

extension PartListTableViewController: ModelSelecting { }

extension PartListTableViewController: Predicating {

    var predicate: NSPredicate? {
        get { return dataSource.fetchRequest.predicate }
        set { dataSource.fetchRequest.predicate = newValue }
    }

}

extension PartListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}
