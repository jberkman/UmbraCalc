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

    private class DataSource: SelectionDataSource<Crew, UITableViewCell> {

        var part: Part? {
            didSet {
                maximumSelectionCount = part?.crewCapacity ?? Int.max
                managedObjectContext = part?.managedObjectContext
            }
        }

        override var selectedModels: Set<DataSource.Model> {
            get { return part?.crew as? Set<Crew> ?? Set() }
            set { part?.crew = newValue }
        }

        override init(sectionOffset: Int = 0) {
            super.init(sectionOffset: sectionOffset)
        }

        override func configureCell(cell: UITableViewCell, forModel model: DataSource.Model) {
            super.configureCell(cell, forModel: model)
            cell.textLabel?.text = model.displayName
            cell.detailTextLabel?.text = model.career
        }

        private override func selectModel(model: Model) {
            model.part = part
        }

        private override func deselectModel(model: Model) {
            model.part = nil
        }

    }

    private lazy var dataSource = DataSource()

    var part: Part? {
        set {
            dataSource.part = newValue
            guard isViewLoaded(), let indexPaths = tableView.indexPathsForVisibleRows else { return }
            tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
        }
        get {
            return dataSource.part
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.fetchRequest.sortDescriptors = [NamedEntity.nameSortDescriptor]
        dataSource.tableView = tableView

        tableView.dataSource = dataSource
        tableView.delegate = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        dataSource.reloadData()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.addSegueIdentifier:
            guard let managedObjectContext = dataSource.managedObjectContext else { break }
            let crewDetail = segue.destinationViewController as! CrewDetailTableViewController
            crewDetail.crew = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withCareer(Crew.pilotTitle)

        default:
            break
        }
    }

}
