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
        var selectionRequiresCrewCapacity = false

        override func configureCell(cell: UITableViewCell, forModel part: Part) {
            cell.textLabel?.text = part.title
            let efficiency = "Efficiency: \(percentFormatter.stringFromNumber(part.efficiency)!)"
            if part.crewCapacity > 0 {
                cell.detailTextLabel?.text = "Crew: \(part.crew?.count ?? 0) of \(part.crewCapacity) \(efficiency)"
            } else {
                cell.detailTextLabel?.text = efficiency
            }
        }

    }

    private(set) var selectedModel: Model?

    private(set) var dataSource: FetchedDataSource<Part, UITableViewCell> = DataSource()

    var vessel: Vessel? {
        didSet {
            managedObjectContext = vessel?.managedObjectContext
            predicate = vessel == nil ? nil : NSPredicate(format: "vessel = %@", vessel!)
            navigationItem.title = vessel?.displayName ?? "Parts"
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Part.showSegueIdentifier:
            let indexPath = tableView.indexPathForCell(sender as! UITableViewCell)!
            let partDetail = segue.destinationViewController as! PartDetailTableViewController
            partDetail.model = dataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
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
