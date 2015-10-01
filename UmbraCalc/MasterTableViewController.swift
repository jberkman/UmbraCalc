//
//  MasterTableViewController.swift
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

class MasterTableViewController: UITableViewController {

    typealias Model = NamedEntity

    private class DataSource: FetchedDataSource<NamedEntity, UITableViewCell> {

        weak var viewController: UIViewController?

        var splitAccessoryType: UITableViewCellAccessoryType {
            return viewController?.splitViewController?.collapsed == false ? .None : .DisclosureIndicator
        }

        init(viewController: UIViewController) {
            self.viewController = viewController
            super.init()
        }

        override func configureCell(cell: UITableViewCell, forModel model: Model) {
            if let kolony = model as? Kolony {
                configureCell(cell, forNamedEntity: kolony)
                cell.detailTextLabel?.text = "\(kolony.crewCount) Crew"
            } else if let vessel = model as? Vessel {
                configureCell(cell, forNamedEntity: vessel)
                cell.detailTextLabel?.text = "\(vessel.crewCount) Crew"
            } else if let crew = model as? Crew {
                configureCell(cell, forCrew: crew)
                cell.detailTextLabel?.text = crew.career
            }
            cell.accessoryType = splitAccessoryType
        }

    }

    @IBOutlet weak var entitySegmentedControl: UISegmentedControl?
    @IBOutlet weak var addButton: UIBarButtonItem?

    private(set) lazy var dataSource: FetchedDataSource<Model, UITableViewCell> = DataSource(viewController: self)

    var selectedModel: Model? {
        didSet {
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if selectedModel != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteEntityWithNotification:", name: willDeleteEntityNotification, object: selectedModel!)
            }
        }
    }

    private var displayedEntityName: String = "" {
        didSet {
            updateEntity()
        }
    }

    private var displayedEntityDescription: NSEntityDescription? {
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

    private var emptyDetailViewController: UIViewController? {
        return storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem()
        dataSource.fetchRequest.sortDescriptors = [NamedEntity.nameSortDescriptor]
        dataSource.tableView = tableView
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        displayedEntityName = Kolony.modelName
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateDetailView()

        let accessoryType = (dataSource as! DataSource).splitAccessoryType
        clearsSelectionOnViewWillAppear = splitViewController?.delegate === self || splitViewController?.collapsed != false
        tableView.visibleCells.forEach {
            $0.accessoryType = accessoryType
            $0.editingAccessoryType = accessoryType
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: cell)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {

        case Base.addSegueIdentifier, Station.addSegueIdentifier:
            guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType(),
                scratchContext = ScratchContext(parentContext: dataSource).managedObjectContext else { return }
            if identifier == Base.addSegueIdentifier {
                vesselDetail.model = try? Base(insertIntoManagedObjectContext: scratchContext)
            } else {
                vesselDetail.model = try? Station(insertIntoManagedObjectContext: scratchContext)
            }

        case Base.showSegueIdentifier, Station.showSegueIdentifier:
            guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType(),
                indexPath = tableView.indexPathForSegueSender(sender),
                vessel = dataSource.modelAtIndexPath(indexPath) as? Vessel else { return }
            vesselDetail.navigationItem.leftBarButtonItem = nil
            vesselDetail.navigationItem.rightBarButtonItem = nil
            vesselDetail.model = vessel
            selectedModel = vessel

        case Crew.addSegueIdentifier:
            guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType(),
                scratchContext = ScratchContext(parentContext: dataSource).managedObjectContext else { return }
            crewDetail.model = try? Crew(insertIntoManagedObjectContext: scratchContext).withCareer(Crew.pilotTitle)

        case Crew.showSegueIdentifier:
            guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType(),
                indexPath = tableView.indexPathForSegueSender(sender),
                crew = dataSource.modelAtIndexPath(indexPath) as? Crew else { return }
            crewDetail.navigationItem.leftBarButtonItem = nil
            crewDetail.navigationItem.rightBarButtonItem = nil
            crewDetail.model = crew
            selectedModel = crew

        case Kolony.addSegueIdentifier:
            break

        case Kolony.showSegueIdentifier:
            break
            
        default:
            break
            
        }
    }

    private func updateEntity() {
        dataSource.fetchRequest.entity = displayedEntityDescription
        guard isViewLoaded() else { return }
        dataSource.reloadData()
    }

    private func updateDetailView() {
        guard splitViewController?.delegate === self && splitViewController?.collapsed == false && tableView.indexPathForSelectedRow == nil else { return }
        guard tableView.numberOfRowsInSection(0) > 0 else {
            guard let viewController = emptyDetailViewController else { return }
            showDetailViewController(viewController, sender: self)
            return
        }
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

}

extension MasterTableViewController {

    @IBAction func addItem(sender: UIBarButtonItem) {
        performSegueWithIdentifier(displayedEntityName.addSegueIdentifier, sender: sender)
    }

    @objc private func willDeleteEntityWithNotification(notification: NSNotification) {
        guard splitViewController?.collapsed == false else {
            selectedModel = nil
            return
        }

        guard let model = dataSource.fetchedModels?.lazy.filter({ $0 != self.selectedModel }).first,
            indexPath = dataSource.indexPathForModel(model) else {
                selectedModel = nil
                guard let viewController = emptyDetailViewController else { return }
                showDetailViewController(viewController, sender: self)
                return
        }

        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }
    
    @IBAction func cancelCrew(segue: UIStoryboardSegue) { }
    @IBAction func cancelKolony(segue: UIStoryboardSegue) { }
    @IBAction func cancelVessel(segue: UIStoryboardSegue) { }

    private func selectModel(model: Model?) {
        guard let model = model, indexPath = dataSource.indexPathForModel(model) else { return }
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        guard let segue = (model as? Segueable)?.showSegueIdentifier else { return }
        performSegueWithIdentifier(segue, sender: indexPath)
    }

    @IBAction func saveCrew(segue: UIStoryboardSegue) {
        guard let crewDetail: CrewDetailTableViewController = segue.destinationViewControllerWithType() else { return }
        _ = try? crewDetail.model?.saveToParentContext(selectModel)
    }

    @IBAction func saveKolony(segue: UIStoryboardSegue) {

    }

    @IBAction func savePart(segue: UIStoryboardSegue) {

    }

    @IBAction func saveVessel(segue: UIStoryboardSegue) {
        guard let vesselDetail: VesselDetailTableViewController = segue.destinationViewControllerWithType() else { return }
        _ = try? vesselDetail.model?.saveToParentContext(nil)
    }

//    @IBAction func addEntitySegue(segue: UIStoryboardSegue) {
//        guard let model: Entity = (segue.sourceViewController as? CrewDetailTableViewController)?.crew ??
//            (segue.sourceViewController as? VesselDetailTableViewController)?.vessel else { return }
//
//        _ = try? entity.saveToParentContext { (entity: Entity?) in
//            guard self.splitViewController?.collapsed == false,
//                let entityToSelect = entity,
//                indexPath = self.dataSource.indexPathOfEntity(entityToSelect) else { return }
//
//            self.performSegueWithIdentifier(self.displayedEntityName.showSegueIdentifier, sender: indexPath)
//        }
//    }

    @IBAction func segmentDidChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: displayedEntityName = Kolony.modelName
        case 1: displayedEntityName = Station.modelName
        case 2: displayedEntityName = Crew.modelName
        default: break
        }
    }

}

extension MasterTableViewController: MutableModelSelecting { }

extension MasterTableViewController: MutableManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }

}

extension MasterTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}

extension MasterTableViewController: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        return emptyDetailViewController
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return secondaryViewController is EmptyDetailViewController
    }

}
