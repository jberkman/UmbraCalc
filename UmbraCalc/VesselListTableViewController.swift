//
//  VesselListTableViewController.swift
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

class VesselListTableViewController: UITableViewController {

    private class DataSource: FetchedDataSource<Vessel, UITableViewCell> {

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

        override func configureCell(cell: UITableViewCell, forModel vessel: Vessel) {
            cell.textLabel?.text = vessel.displayName
            cell.detailTextLabel?.text = "Crew: \(vessel.crewCount) of \(vessel.crewCapacity) Happiness: \(percentFormatter.stringFromNumber(vessel.crewHappiness)!) Parts: \(vessel.partCount)"
        }

    }

    private(set) var dataSource: FetchedDataSource<Vessel, UITableViewCell> = DataSource()

    var kolony: Kolony? {
        didSet {
            managedObjectContext = kolony?.managedObjectContext
            predicate = kolony == nil ? nil : NSPredicate(format: "kolony = %@", kolony!)
            navigationItem.title = kolony?.displayName
            guard isViewLoaded() else { return }
            dataSource.reloadData()
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Part.showListSegueIdentifier:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let partList = segue.destinationViewController as! PartSelectionTableViewController
            partList.vessel = dataSource.modelAtIndexPath(indexPath)

        case Vessel.showSegueIdentifier:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let vesselDetail = segue.destinationViewController as! VesselDetailTableViewController
            vesselDetail.model = dataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

}

extension VesselListTableViewController: MutableManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }
    
}

extension VesselListTableViewController: MutablePredicating {

    var predicate: NSPredicate? {
        get { return dataSource.fetchRequest.predicate }
        set { dataSource.fetchRequest.predicate = newValue }
    }

}

extension VesselListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}
