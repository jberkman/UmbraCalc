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

    private class DataSource: FetchedDataSource<NamedEntity, UITableViewCell> {

        weak var viewController: UIViewController?

        var splitAccessoryType: UITableViewCellAccessoryType {
            return viewController?.splitViewController?.collapsed == false ? .None : .DisclosureIndicator
        }

        init(viewController: UIViewController) {
            self.viewController = viewController
            super.init()
        }

        override func configureCell(cell: UITableViewCell, forModel model: DataSource.Model) {
            if let kolony = model as? Kolony {
                cell.textLabel?.text = kolony.displayName
                let baseCount = kolony.bases?.count ?? 0
                cell.detailTextLabel?.text = baseCount == 1 ? "\(baseCount) Base" : "\(baseCount) Bases"
            } else if let vessel = model as? Station {
                cell.textLabel?.text = vessel.displayName
                cell.detailTextLabel?.text = "\(vessel.crewCount) Crew"
            } else if let crew = model as? Crew {
                cell.textLabel?.text = crew.displayName
                cell.detailTextLabel?.text = crew.career
            }
            cell.accessoryType = splitAccessoryType
        }

    }

    @IBOutlet weak var entitySegmentedControl: UISegmentedControl?
    @IBOutlet weak var addButton: UIBarButtonItem?

    private lazy var dataSource: DataSource = { return DataSource(viewController: self) }()

    var managedObjectContext: NSManagedObjectContext? {
        get { return dataSource.managedObjectContext }
        set { dataSource.managedObjectContext = newValue }
    }

    var selectedEntity: DataSource.Model? {
        didSet {
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if selectedEntity != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteEntityWithNotification:", name: willDeleteEntityNotification, object: selectedEntity!)
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
        dataSource.fetchRequest.sortDescriptors = [DataSource.Model.nameSortDescriptor]
        dataSource.tableView = tableView
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard dataSource.fetchedResultsController == nil else { return }
        displayedEntityName = Kolony.modelName
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateDetailView()

        let accessoryType = dataSource.splitAccessoryType
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
        let destinationViewController = (segue.destinationViewController as? UINavigationController)?.viewControllers.first

        switch segue.identifier! {
        case Crew.showSegueIdentifier:
            guard let indexPath = tableView.indexPathForSegueSender(sender) else { return }
            let controller = destinationViewController as! CrewDetailTableViewController
            controller.crew = dataSource.modelAtIndexPath(indexPath) as? Crew
            selectedEntity = controller.crew

        case Kolony.showSegueIdentifier:
            guard let indexPath = tableView.indexPathForSegueSender(sender) else { return }
            let controller = destinationViewController as! KolonyDetailTableViewController
            controller.kolony = dataSource.modelAtIndexPath(indexPath) as? Kolony
            selectedEntity = controller.kolony

        case Station.showSegueIdentifier:
            guard let indexPath = tableView.indexPathForSegueSender(sender) else { return }
            let controller = destinationViewController as! VesselDetailTableViewController
            controller.vessel = dataSource.modelAtIndexPath(indexPath) as? Vessel
            selectedEntity = controller.vessel

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

    @IBAction func addModel(sender: UIBarButtonItem) {
        guard let managedObjectContext = managedObjectContext else { return }
        let model: DataSource.Model!

        switch displayedEntityName {
        case Crew.modelName:
            model = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withCareer(Crew.engineerTitle)

        case Kolony.modelName:
            model = try? Kolony(insertIntoManagedObjectContext: managedObjectContext).withBases([Base(insertIntoManagedObjectContext: managedObjectContext).withDefaultParts()])

        case Station.modelName:
            model = try? Station(insertIntoManagedObjectContext: managedObjectContext).withDefaultParts()

        default:
            fatalError("Unhandled model: \(displayedEntityName)")
        }

        guard model != nil else { return }
        managedObjectContext.processPendingChanges()

        guard let indexPath = dataSource.indexPathForModel(model) else { return }
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: indexPath)
    }
    
    @objc private func willDeleteEntityWithNotification(notification: NSNotification) {
        guard splitViewController?.collapsed == false else {
            selectedEntity = nil
            return
        }

        guard let model = dataSource.fetchedModels?.lazy.filter({ $0 != self.selectedEntity }).first,
            indexPath = dataSource.indexPathForModel(model) else {
                selectedEntity = nil
                guard let viewController = emptyDetailViewController else { return }
                showDetailViewController(viewController, sender: self)
                return
        }

        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    @IBAction func segmentDidChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: displayedEntityName = Kolony.modelName
        case 1: displayedEntityName = Station.modelName
        case 2: displayedEntityName = Crew.modelName
        default: break
        }
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
