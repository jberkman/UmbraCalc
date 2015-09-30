//
//  NamedEntityTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-29.
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

class ManagedTableViewController: UITableViewController {

    typealias Entity = NSManagedObject

    lazy var dataSource: ManagedDataSource<Entity, UITableViewCell> = ManagedDataSource()
    var selectedObject: Entity?

    var displayedEntityName: String = "" {
        didSet {
            updateEntity()
        }
    }

    var displayedEntityDescription: NSEntityDescription? {
        func descriptionWithManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
            guard let entities = managedObjectContext.persistentStoreCoordinator?.managedObjectModel.entities else {
                guard let parent = managedObjectContext.parentContext else { return nil }
                return descriptionWithManagedObjectContext(parent)
            }
            return entities.lazy.filter { $0.name == self.displayedEntityName }.first
        }
        guard let context = dataSource.managedObjectContext else { return nil }
        return descriptionWithManagedObjectContext(context)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        dataSource.delegate = self
        dataSource.fetchRequest.sortDescriptors = NamedEntity.sortDescriptors
        dataSource.tableView = tableView
    }

    private func updateEntity() {
        dataSource.fetchRequest.entity = displayedEntityDescription
        guard isViewLoaded() else { return }
        dataSource.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        updateEntity()
    }


    @IBAction func addItem(sender: UIBarButtonItem) {
        performSegueWithIdentifier(displayedEntityName.addSegueIdentifier, sender: sender)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: cell)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {

        case Base.addSegueIdentifier, Station.addSegueIdentifier:
            guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType() else { return }
            let scratchContext = ScratchContext(parent: dataSource)
            let isBase = identifier == Base.addSegueIdentifier
            vesselDetail.vessel = isBase ? scratchContext.insertBase() : scratchContext.insertStation()

        case Base.showSegueIdentifier, Station.showSegueIdentifier:
            guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType(),
                indexPath = tableView.indexPathForSegueSender(sender),
                vessel = dataSource.entityAtIndexPath(indexPath) as? Vessel else { return }
            vesselDetail.vessel = vessel
            vesselDetail.navigationItem.leftBarButtonItem = nil
            vesselDetail.navigationItem.rightBarButtonItem = nil
            selectedObject = vessel

        case Crew.addSegueIdentifier:
            guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType() else { return }
            let scratchContext = ScratchContext(parent: dataSource)
            crewDetail.crew = scratchContext.insertCrew()?.withCareer(Crew.pilotTitle)

        case Crew.showSegueIdentifier:
            guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType(),
                indexPath = tableView.indexPathForSegueSender(sender),
                crew = dataSource.entityAtIndexPath(indexPath) as? Crew else { return }
            crewDetail.crew = crew
            crewDetail.navigationItem.leftBarButtonItem = nil
            crewDetail.navigationItem.rightBarButtonItem = nil
            selectedObject = crew

        case Kolony.addSegueIdentifier:
            break

        case Kolony.showSegueIdentifier:
            break

        default:
            break

        }
    }

    @IBAction func cancelAddEntitySegue(ssegue: UIStoryboardSegue) { }

    @IBAction func addEntitySegue(segue: UIStoryboardSegue) {
        guard let entity: Entity = (segue.sourceViewController as? CrewDetailTableViewController)?.crew ??
            (segue.sourceViewController as? VesselDetailTableViewController)?.vessel else { return }

        _ = try? entity.saveToParentContext { (entity: Entity?) in
            guard self.splitViewController?.collapsed == false,
                let entityToSelect = entity,
                indexPath = self.dataSource.indexPathOfEntity(entityToSelect) else { return }

            self.performSegueWithIdentifier(self.displayedEntityName.showSegueIdentifier, sender: indexPath)
        }
    }

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        if let kolony = entity as? Kolony {
            dataSource.configureCell(cell, forNamedEntity: kolony)
            cell.detailTextLabel?.text = "\(kolony.crewCount) Crew"
        } else if let vessel = entity as? Vessel {
            dataSource.configureCell(cell, forNamedEntity: vessel)
            cell.detailTextLabel?.text = "\(vessel.crewCount) Crew"
        } else if let crew = entity as? Crew {
            dataSource.configureCell(cell, forCrew: crew)
            cell.detailTextLabel?.text = crew.career
        }
    }

}

extension ManagedTableViewController: ManagedDataSourceDelegate { }

extension ManagedTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
        updateEntity()
    }

}
