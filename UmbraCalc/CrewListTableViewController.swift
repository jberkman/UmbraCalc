//
//  CrewListTableViewController.swift
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

class CrewListTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!

    private lazy var dataSource: FetchedDataSource<Crew, UITableViewCell> = FetchedDataSource()

    private var currentAccessoryType: UITableViewCellAccessoryType {
        return splitViewController?.collapsed == false ? .None : .DisclosureIndicator
    }

    private var selectedCrew: Crew? {
        didSet {
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if selectedCrew != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteCrewWithNotification:", name: willDeleteEntityNotification, object: selectedCrew!)
            }
            showEmptyDetailViewController = false
        }
    }

    private var showEmptyDetailViewController = false

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()

        dataSource.configureCell = { [weak self] (cell: UITableViewCell, crew: Crew) in
            guard self != nil else { return }
            cell.textLabel?.text = crew.name
            let starString = String(count: Int(crew.starCount), repeatedValue: "⭐️")
            if let career = crew.career {
                cell.detailTextLabel?.text = "\(career) \(starString)"
            } else {
                cell.detailTextLabel?.text = starString.isEmpty ? "0 Stars" : starString
            }
            let accessoryType = self!.currentAccessoryType
            cell.accessoryType = accessoryType
            cell.editingAccessoryType = accessoryType
        }

        dataSource.tableView = tableView

        let fetchRequest = NSFetchRequest(entityName: "Crew")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.fetchRequest = fetchRequest
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateVisibleAccessoryTypes()
        updateDetailView()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        print(__FUNCTION__, identifier)
        switch identifier {
        case "insertCrew":
            guard let crewDetail = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController else { return }

            let scratchContext = ScratchContext(parent: dataSource)
            crewDetail.crew = scratchContext.insertCrew()!.withCareer(Crew.pilotTitle)
            crewDetail.navigationItem.title = "Add Crew"
            crewDetail.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "crewDetailViewControllerDidCancel")
            crewDetail.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "crewDetailViewControllerDidFinish")
            crewDetail.editing = true

        case "editCrew":
            guard let crewDetail = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController,
                indexPath = sender is UITableViewCell ? tableView.indexPathForCell(sender as! UITableViewCell) : sender as? NSIndexPath,
                crew = dataSource.entityAtIndexPath(indexPath) else { return }

            crewDetail.crew = crew
            crewDetail.navigationItem.rightBarButtonItem = crewDetail.editButtonItem()
            selectedCrew = crew

        default:
            break
        }
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateVisibleAccessoryTypes()
    }

    private func updateDetailView() {
        guard splitViewController?.collapsed == false && tableView.indexPathForSelectedRow == nil else { return }
        guard tableView.numberOfRowsInSection(0) > 0 else {
            guard let emptyDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController") else { return }
            showDetailViewController(emptyDetailViewController, sender: self)
            return
        }
        editCrewAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
    }

    private func updateVisibleAccessoryTypes() {
        let accessoryType = currentAccessoryType
        tableView.visibleCells.forEach {
            $0.accessoryType = accessoryType
            $0.editingAccessoryType = accessoryType
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.setLeftBarButtonItem(editing || navigationController?.viewControllers.first == self ? addButton : nil, animated: animated)
    }

    private func editCrewAtIndexPath(indexPath: NSIndexPath) {
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        performSegueWithIdentifier("editCrew", sender: indexPath)
    }

}

extension CrewListTableViewController {

    @objc private func crewDetailViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func crewDetailViewControllerDidFinish() {
        guard let crewDetail = (presentedViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController else { return }
        dismissViewControllerAnimated(true) {
            guard let crew = crewDetail.crew else { return }
            try! crew.managedObjectContext!.obtainPermanentIDsForObjects([crew])
            let objectID = crew.objectID
            try! crew.managedObjectContext!.save()
            
            guard self.splitViewController?.collapsed == false,
                let crewToSelect = self.dataSource.managedObjectContext?.objectWithID(objectID) as? Crew,
                indexPath = self.dataSource.indexPathOfEntity(crewToSelect) else { return }
            self.editCrewAtIndexPath(indexPath)
        }
    }

}

extension CrewListTableViewController {

    @objc private func willDeleteCrewWithNotification(notification: NSNotification) {
        guard splitViewController?.collapsed == false else {
            selectedCrew = nil
            return
        }

        guard let crew = dataSource.entities?.lazy.filter({ $0 != self.selectedCrew }).first,
            indexPath = dataSource.indexPathOfEntity(crew) else {
                selectedCrew = nil
                guard let empty = storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController") else { return }
                showDetailViewController(empty, sender: self)
                return
        }

        editCrewAtIndexPath(indexPath)
    }

}

extension CrewListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}

extension CrewListTableViewController: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard selectedCrew == nil else { return nil }
        return storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController")
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return secondaryViewController is EmptyDetailViewController
    }

}
