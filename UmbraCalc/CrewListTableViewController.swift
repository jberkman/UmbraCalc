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
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }

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
                cell = sender as? UITableViewCell,
                indexPath = tableView.indexPathForCell(cell),
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

    private func updateVisibleAccessoryTypes() {
        let accessoryType = currentAccessoryType
        tableView.visibleCells.forEach {
            $0.accessoryType = accessoryType
            $0.editingAccessoryType = accessoryType
        }
    }

    @objc private func crewDetailViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.setLeftBarButtonItem(editing || navigationController?.viewControllers.first == self ? addButton : nil, animated: animated)
    }

    @objc private func crewDetailViewControllerDidFinish() {
        guard let crewDetail = (presentedViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController else { return }

        crewDetail.setEditing(false, animated: false)
        try! crewDetail.crew!.managedObjectContext!.save()

        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func willDeleteCrewWithNotification(notification: NSNotification) {
        selectedCrew = nil
        showEmptyDetailViewController = splitViewController?.collapsed == true
    }

}

extension CrewListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}

extension CrewListTableViewController: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard showEmptyDetailViewController else { return nil }
        showEmptyDetailViewController = false
        return storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController")
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return secondaryViewController is EmptyDetailViewController
    }

}
