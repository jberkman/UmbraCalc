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

        let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

        override init(sectionOffset: Int = 0) {
            super.init(sectionOffset: sectionOffset)
        }
        
        override func configureCell(cell: UITableViewCell, forModel vessel: Vessel) {
            cell.textLabel?.text = vessel.displayName
            cell.detailTextLabel?.text = "Crew: \(vessel.crewCount) of \(vessel.crewCapacity) Happiness: \(percentFormatter.stringFromNumber(vessel.crewHappiness)!) Parts: \(vessel.partCount)"
        }

    }

    private lazy var dataSource = DataSource()

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }

    var kolony: Kolony? {
        didSet {
            managedObjectContext = kolony?.managedObjectContext
            if let managedObjectContext = managedObjectContext {
                dataSource.fetchRequest.entity = NSEntityDescription.entityForName(Base.modelName, inManagedObjectContext: managedObjectContext)
            } else {
                dataSource.fetchRequest.entity = nil
            }
            dataSource.fetchRequest.predicate = kolony == nil ? nil : NSPredicate(format: "kolony = %@", kolony!)
            navigationItem.title = kolony?.displayName
            guard isViewLoaded() else { return }
            dataSource.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.fetchRequest.sortDescriptors = [NamedEntity.nameSortDescriptor]
        dataSource.tableView = tableView
        
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else {
            guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
            return
        }
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Base.addSegueIdentifier:
            guard let managedObjectContext = managedObjectContext where kolony != nil else { return }
            let baseDetail = segue.destinationViewController as! VesselDetailTableViewController
            baseDetail.vessel = try? Base(insertIntoManagedObjectContext: managedObjectContext).withKolony(kolony) //.withDefaultParts()

        case Base.showSegueIdentifier:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let vesselDetail = segue.destinationViewController as! VesselDetailTableViewController
            vesselDetail.vessel = dataSource.modelAtIndexPath(indexPath)

        case Part.showListSegueIdentifier:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let partList = segue.destinationViewController as! PartSelectionTableViewController
            partList.vessel = dataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

}
