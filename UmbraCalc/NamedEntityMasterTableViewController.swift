//
//  NamedEntityMasterTableViewController.swift
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

class NamedEntityMasterTableViewController: MasterTableViewController {

    enum EntityDescription: String {
        case Kolony = "Kolony"
        case Station = "Station"
        case Crew = "Crew"
        case Base = "Base"

        func entityWithManagedObjectContext(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
            guard let entities = managedObjectContext.persistentStoreCoordinator?.managedObjectModel.entities else {
                guard let parent = managedObjectContext.parentContext else { return nil }
                return entityWithManagedObjectContext(parent)
            }
            return entities.lazy.filter { $0.name == self.rawValue }.first
        }

        var showSegueIdentifier: String { return "show\(rawValue)" }
        var addSegueIdentifier: String { return "add\(rawValue)" }

    }

    @IBOutlet weak var entitySegmentedControl: UISegmentedControl?
    private var ignoreSegmentChanges = false

    lazy var dataSource: MasterDataSource<NamedEntity, UITableViewCell> = MasterDataSource()

    var entityDescription: EntityDescription = .Kolony {
        didSet {
            editSegueIdentifier = entityDescription.showSegueIdentifier
            updateEntity()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        dataSource.delegate = self
        dataSource.fetchRequest.sortDescriptors = NamedEntity.sortDescriptors
        dataSource.tableViewController = self
        entityDescription = .Kolony
    }

    private func updateEntity() {
        guard let managedObjectContext = dataSource.managedObjectContext else { return }
        dataSource.fetchRequest.entity = entityDescription.entityWithManagedObjectContext(managedObjectContext)

        guard isViewLoaded() else { return }
        dataSource.reloadData()
    }

    @IBAction func segmentDidChange(sender: UISegmentedControl) {
        guard let newEntity: EntityDescription = {
            switch sender.selectedSegmentIndex {
            case 0: return .Kolony
            case 1: return .Station
            case 2: return .Crew
            default: return nil
            }
            }() else { return }
        entityDescription = newEntity
    }

    @IBAction func addItem(sender: UIBarButtonItem) {
        performSegueWithIdentifier(entityDescription.addSegueIdentifier, sender: sender)
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        performSegueWithIdentifier(entityDescription.showSegueIdentifier, sender: cell)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {

        case EntityDescription.Base.addSegueIdentifier, EntityDescription.Station.addSegueIdentifier:
            guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType() else { return }
            let scratchContext = ScratchContext(parent: dataSource)
            let isBase = identifier == EntityDescription.Base.addSegueIdentifier
            vesselDetail.vessel = isBase ? scratchContext.insertBase() : scratchContext.insertStation()

        case EntityDescription.Base.showSegueIdentifier, EntityDescription.Station.showSegueIdentifier:
            guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType(),
                indexPath = tableView.indexPathForSegueSender(sender),
                vessel = dataSource.entityAtIndexPath(indexPath) as? Vessel else { return }
            vesselDetail.vessel = vessel
            dataSource.selectedEntity = vessel

        case EntityDescription.Crew.addSegueIdentifier:
            guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType() else { return }
            let scratchContext = ScratchContext(parent: dataSource)
            crewDetail.crew = scratchContext.insertCrew()

        case EntityDescription.Crew.showSegueIdentifier:
            guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType(),
                indexPath = tableView.indexPathForSegueSender(sender),
                crew = dataSource.entityAtIndexPath(indexPath) as? Crew else { return }
            crewDetail.crew = crew
            dataSource.selectedEntity = crew

        case EntityDescription.Kolony.addSegueIdentifier:
            break

        case EntityDescription.Kolony.showSegueIdentifier:
            break

        default:
            break

        }
    }

}

extension NamedEntityMasterTableViewController: ManagedDataSourceDelegate {

    func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        switch entityDescription {
        case .Kolony:
            guard let kolony = entity as? Kolony else { break }
            dataSource.configureCell(cell, forNamedEntity: kolony)
            cell.detailTextLabel?.text = "\(kolony.crewCount) Crew"

        case .Station, .Base:
            guard let vessel = entity as? Vessel else { break }
            dataSource.configureCell(cell, forNamedEntity: vessel)
            cell.detailTextLabel?.text = "\(vessel.crewCount) Crew"

        case .Crew:
            guard let crew = entity as? Crew else { return }
            dataSource.configureCell(cell, forCrew: crew)
            cell.detailTextLabel?.text = crew.career

        }
        let accessoryType = splitAccessoryType
        cell.accessoryType = accessoryType
        cell.editingAccessoryType = accessoryType
    }

}

extension NamedEntityMasterTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
        updateEntity()
    }

}

extension NamedEntityMasterTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
