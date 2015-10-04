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
            super.configureCell(cell, forModel: crew)
            cell.textLabel?.text = crew.displayName
            cell.detailTextLabel?.text = crew.career
        }

    }

    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    private(set) lazy var dataSource: SelectionDataSource<Crew, UITableViewCell> = DataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.tableViewDelegate = self
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
        case Crew.addSegueIdentifier:
            guard let scratchContext = ScratchContext(parentContext: dataSource).managedObjectContext else { return }
            let navigationController = segue.destinationViewController as! UINavigationController
            let crewDetail = navigationController.viewControllers.first as! CrewDetailTableViewController
            crewDetail.model = try? Crew(insertIntoManagedObjectContext: scratchContext).withCareer(Crew.pilotTitle)
            crewDetail.navigationItem.leftBarButtonItem = crewDetail.cancelButtonItem
            crewDetail.navigationItem.rightBarButtonItem = crewDetail.saveButtonItem

        default:
            break
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.setRightBarButtonItem(editing ? addButtonItem : nil, animated: animated)
    }

    @IBAction func cancelCrew(segue: UIStoryboardSegue) { }

    @IBAction func saveCrew(segue: UIStoryboardSegue) {
        let crewDetail = segue.sourceViewController as! CrewDetailTableViewController
        _ = try? crewDetail.model?.saveToParentContext {
            guard let crew = $0 as? Crew where self.selectedModels.count < self.maximumSelectionCount else { return }
            self.selectedModels.insert(crew)

            guard let indexPath = self.dataSource.indexPathForModel(crew) else { return }
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
        }
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

extension CrewSelectionTableViewController: MutablePredicating {

    var predicate: NSPredicate? {
        get { return dataSource.fetchRequest.predicate }
        set { dataSource.fetchRequest.predicate = newValue }
    }

}

extension CrewSelectionTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}
