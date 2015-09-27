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

    private lazy var dataSource: FetchedDataSource<Crew, UITableViewCell> = FetchedDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.configureCell = { (cell: UITableViewCell, crew: Crew) in
            cell.textLabel?.text = crew.name
            guard let career = crew.career else {
                cell.detailTextLabel?.text = "\(crew.starCount) Stars"
                return
            }
            cell.detailTextLabel?.text = "\(crew.starCount)-Star \(career)"
        }

        dataSource.tableView = tableView

        let fetchRequest = NSFetchRequest(entityName: "Crew")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        dataSource.fetchRequest = fetchRequest
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "insertCrew":
            guard let crewDetail = (segue.destinationViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController else { return }

            let scratchContext = ScratchContext(parent: dataSource)
            crewDetail.crew = scratchContext.insertCrew()!.withCareer(Crew.pilotTitle)
            crewDetail.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "crewDetailViewControllerDidCancel")
            crewDetail.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "crewDetailViewControllerDidFinish")
            crewDetail.editing = true

        case "editCrew":
            guard let crewDetail = segue.destinationViewController as? CrewDetailTableViewController,
                cell = sender as? UITableViewCell,
                indexPath = tableView.indexPathForCell(cell),
                crew = dataSource.entityAtIndexPath(indexPath) else { return }

            crewDetail.crew = crew
            crewDetail.navigationItem.rightBarButtonItem = crewDetail.editButtonItem()

        default:
            break
        }
    }

    @objc private func crewDetailViewControllerDidCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func crewDetailViewControllerDidFinish() {
        guard let crewDetail = (presentedViewController as? UINavigationController)?.viewControllers.first as? CrewDetailTableViewController else { return }

        crewDetail.setEditing(false, animated: false)
        try! crewDetail.crew!.managedObjectContext!.save()

        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension CrewListTableViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        dataSource.managedObjectContext = managingObjectContext.managedObjectContext
    }
    
}
