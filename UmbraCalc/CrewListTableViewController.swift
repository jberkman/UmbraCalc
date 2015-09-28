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

class CrewListTableViewController: MasterTableViewController {

    private(set) lazy var dataSource: CrewFetchedDataSource<Crew, UITableViewCell> = CrewFetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        let configureCell = dataSource.configureCell
        dataSource.configureCell = { [weak self] (cell: UITableViewCell, crew: Crew) in
            guard self != nil else { return }
            configureCell?(cell: cell, entity: crew)
            let accessoryType = self!.currentAccessoryType
            cell.accessoryType = accessoryType
            cell.editingAccessoryType = accessoryType
        }
        dataSource.tableViewController = self
        dataSource.reloadData()
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

        case "editCrew", "viewCrew":
            guard let crewDetail = segue.destinationViewController as? CrewDetailTableViewController ??
                (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController,
                indexPath = sender is UITableViewCell ? tableView.indexPathForCell(sender as! UITableViewCell) : sender as? NSIndexPath,
                crew = dataSource.entityAtIndexPath(indexPath) else { return }

            crewDetail.crew = crew
            if identifier == "editCrew" {
                crewDetail.navigationItem.rightBarButtonItem = crewDetail.editButtonItem()
            }
            dataSource.selectedEntity = crew

        default:
            break
        }
    }

    override func showDetailViewControllerForEntityAtIndexPath(indexPath: NSIndexPath) {
        performSegueWithIdentifier("editCrew", sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    // Crew detail button handlers
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
            self.showDetailViewControllerForEntityAtIndexPath(indexPath)
        }
    }

}

extension CrewListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }

}

extension CrewListTableViewController {

    override func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        guard dataSource.selectedEntity == nil else { return nil }
        return super.splitViewController(splitViewController, separateSecondaryViewControllerFromPrimaryViewController: primaryViewController)
    }
}
