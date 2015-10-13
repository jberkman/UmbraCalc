//
//  ResourceDetailTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-11.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import Foundation
import JeSuis
import UIKit

class ResourceDetailTableViewController: UITableViewController {

    class ResourceRow: Row {
        private let resource: ResourceConverting

        init(reuseIdentifier: String, resource: ResourceConverting, configureCell: (cell: UITableViewCell, indexPath: NSIndexPath, resource: ResourceConverting) -> Void) {
            self.resource = resource
            super.init(reuseIdentifier: reuseIdentifier) {
                configureCell(cell: $0, indexPath: $1, resource: resource)
            }
        }
    }

    var kolonizingCollection: KolonizingCollectionType? {
        didSet {
            guard isViewLoaded() else { return }
            updateDataSource()
        }
    }

    var resourceName: String? {
        didSet {
            navigationItem.title = resourceName
            guard isViewLoaded() else { return }
            updateDataSource()
        }
    }

    private var dataSource: StaticDataSource? {
        didSet {
            tableView.dataSource = dataSource
            guard isViewLoaded() else { return }
            tableView.reloadData()
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case Crew.showSegueIdentifier:
            let crewDetails = segue.destinationViewController as! CrewDetailTableViewController
            let indexPath = tableView.indexPathForSegueSender(sender)!
            crewDetails.crew = ((dataSource![indexPath] as! ResourceRow).resource as! Crew)

        case Part.showSegueIdentifier:
            let partDetails = segue.destinationViewController as! PartDetailTableViewController
            let indexPath = tableView.indexPathForSegueSender(sender)!
            partDetails.part = ((dataSource![indexPath] as! ResourceRow).resource as! Part)

        default:
            break

        }
    }

    private func updateDataSource() {
        guard let collection = kolonizingCollection, resourceName = resourceName else {
            dataSource = nil
            return
        }

        let parts = collection.kolonizingCollection.map { $0 as ResourceConverting }
        let crew = collection.crewingCollection.map { $0 as ResourceConverting }

        func name(object: ResourceConverting) -> String {
            return (object as? Crew)?.crewDisplayName ?? (object as? Part)?.displayName ?? ""
        }

        func reuseIdentifier(resource: ResourceConverting) -> String {
            return resource is Crew ? "crewCell"
                : (resource as? Crewable)?.crewed == true ? "crewedCell"
                : "uncrewedCell"
        }

        let converters = (parts + crew).sort { name($0) < name($1) }

        let producers = converters.filter { $0.outputResources[resourceName] != nil }
        let consumers = converters.filter { $0.inputResources[resourceName] != nil }

        let constrainedOutputs = collection.constrainedOutputs
        let inputConstraints = collection.initialSupplyInputConstraintsWithOutputResources(constrainedOutputs)
        let crewInputs = collection.crewingCollection.map{ $0.inputResources }.reduce([:], combine: +)
        let netResources = constrainedOutputs - inputConstraints * collection.inputResources - crewInputs

        dataSource = StaticDataSource(sections: [
            Section(rows: producers.map {
                ResourceRow(reuseIdentifier: reuseIdentifier($0), resource: $0) {
                    $0.textLabel?.text = name($2)
                    let constrainedOutputs: [String: Double]
                    if let resourceCollection = ($2 as? ResourceConvertingCollectionType)?.resourceConvertingCollection {
                        constrainedOutputs = resourceCollection.map { $0.outputResourcesWithInputConstraints(inputConstraints) }.reduce([:], combine: +)
                    } else {
                        constrainedOutputs = $2.outputResources
                    }
                    $0.detailTextLabel?.text = "\((constrainedOutputs[resourceName] ?? 0) * secondsPerDay) / day"
                }
                }, headerTitle: "Producers", footerTitle: nil),
            Section(rows: consumers.map {
                ResourceRow(reuseIdentifier: reuseIdentifier($0), resource: $0) {
                    $0.textLabel?.text = name($2)
                    let inputResources = $2 is Crewing ? $2.inputResources : $2.inputResources * inputConstraints
                    $0.detailTextLabel?.text = "\((inputResources[resourceName] ?? 0) * secondsPerDay) / day"
                }
                }, headerTitle: "Consumers", footerTitle: nil),
            Section(rows: [
                Row(reuseIdentifier: "dailyCell") { cell, _ in
                    cell.detailTextLabel?.text = String((netResources[resourceName] ?? 0) * secondsPerDay)
                },
                Row(reuseIdentifier: "yearlyCell") { cell, _ in
                    cell.detailTextLabel?.text = String((netResources[resourceName] ?? 0) * secondsPerYear)
                }
                ], headerTitle: "Totals", footerTitle: nil)
            ])
    }

}