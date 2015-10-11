//
//  PartDetailTableViewController.swift
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

private let efficiencyPart = "EfficiencyPart"

class PartDetailTableViewController: UITableViewController {

    private class EfficiencyPartDataSource: NSObject, OffsettableDataSource {

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

        lazy var partNodes: [PartNode] = bundledPartNodes

        var reuseIdentifier = "efficiencyPartCell"
        let sectionOffset: Int

        private var part: Part? {
            didSet {
                partNodes = EfficiencyPartDataSource.bundledPartNodes.filter { self.part?.efficiencyFactors[$0.name] != nil }
            }
        }

        static var bundledPartNodes: [PartNode] {
            return NSBundle.mainBundle().partNodes
                .filter { !$0.title.lowercaseString.containsString("legacy") }
                .sort {
                    func awesomeness(partNode: PartNode) -> Int {
                        return partNode.crewCapacity + partNode.livingSpaceCount + partNode.workspaceCount
                    }
                    let (lhs, rhs) = (awesomeness($0) > 0, awesomeness($1) > 0)
                    return (lhs && !rhs) || (lhs == rhs && $0.title < $1.title)
            }
        }

        init(sectionOffset: Int) {
            self.sectionOffset = sectionOffset
            super.init()
        }

        @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return partNodes.count
        }

        func partNodeForRowAtIndexPath(indexPath: NSIndexPath) -> PartNode {
            return partNodes[indexPath.row]
        }

        @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
            let partNode = partNodeForRowAtIndexPath(indexPath)
            cell.textLabel?.text = partNode.title
            guard let vesselEfficiencyParts = part?.crewableCollection?.containingKolonizingCollection?.kolonizingCollection,
                rate = part?.efficiencyFactors[partNode.name],
                rateString = percentFormatter.stringFromNumber(rate) else { return cell }
            let count = vesselEfficiencyParts.map { $0.name == partNode.name ? ($0 as? Countable)?.count ?? 0 : 0 }.reduce(0, combine: +)
            cell.detailTextLabel?.text = "\(count) x \(rateString)"
            return cell
        }

    }

    @IBOutlet weak var careerFactorLabel: UILabel!
    @IBOutlet weak var crewCapacityLabel: UILabel!
    @IBOutlet weak var crewEfficiencyLabel: UILabel!
    @IBOutlet weak var efficiencyLabel: UILabel!
    @IBOutlet weak var happinessLabel: UILabel!
    @IBOutlet weak var partsEfficiencyLabel: UILabel!

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    private lazy var dataSource: StoryboardDelegatedDataSource = StoryboardDelegatedDataSource(dataSource: self)
    private lazy var efficiencyPartDataSource = EfficiencyPartDataSource(sectionOffset: 1)
    private lazy var crewDataSource = CrewSelectionDataSource(sectionOffset: 7)

    var part: Part? {
        didSet {
            crewDataSource.part = part
            efficiencyPartDataSource.part = part
            if part?.efficiencyFactors.isEmpty == false {
                dataSource.registerDataSource(efficiencyPartDataSource)
            } else {
                dataSource.unregisterDataSource(efficiencyPartDataSource)
            }
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(Value1TableViewCell.self, forCellReuseIdentifier: crewDataSource.reuseIdentifier)
        dataSource.registerDataSource(crewDataSource)
        crewDataSource.tableView = tableView
        crewDataSource.fetchRequest.sortDescriptors = [Crew.nameSortDescriptor]

        tableView.registerClass(Value1TableViewCell.self, forCellReuseIdentifier: efficiencyPartDataSource.reuseIdentifier)

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        if crewDataSource.fetchedResultsController == nil {
            crewDataSource.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.addSegueIdentifier:
            let navigationController = segue.destinationViewController as! UINavigationController
            let crewDetail = navigationController.viewControllers.first as! CrewDetailTableViewController

            let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            context.parentContext = part?.managedObjectContext

            crewDetail.crew = try? Crew(insertIntoManagedObjectContext: context).withCareer(Crew.pilotTitle)
            crewDetail.navigationItem.leftBarButtonItem = crewDetail.cancelButtonItem
            crewDetail.navigationItem.rightBarButtonItem = crewDetail.saveButtonItem

        default:
            break
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case Crew.showListSegueIdentifier:
            return part?.crewed == true

        default:
            return true
        }
    }

    private func updateView() {
        guard isViewLoaded() else { return }
        navigationItem.title = part?.title

        careerFactorLabel.text = percentFormatter.stringFromNumber(part?.careerFactor ?? 0)
        crewCapacityLabel.text = "\(part?.crewCount ?? 0) of \(part?.crewCapacity ?? 0)"
        crewEfficiencyLabel.text = percentFormatter.stringFromNumber(part?.crewingEfficiency ?? 0)
        happinessLabel.text = percentFormatter.stringFromNumber(part?.vessel?.happiness ?? 0)
        partsEfficiencyLabel.text = percentFormatter.stringFromNumber(part?.kolonizingEfficiency ?? 0)
        efficiencyLabel.text = percentFormatter.stringFromNumber(part?.efficiency ?? 0)
    }

}

extension PartDetailTableViewController {

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case crewDataSource.sectionOffset:
            return crewDataSource.tableView(tableView, shouldHighlightRowAtIndexPath: indexPath)

        default:
            return false
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case crewDataSource.sectionOffset:
            crewDataSource.tableView(tableView, didSelectRowAtIndexPath: indexPath)
            updateView()

        default:
            break
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case crewDataSource.sectionOffset, efficiencyPartDataSource.sectionOffset:
            return 44

        default:
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0 // super.tableView(tableView, indentationLevelForRowAtIndexPath: storyboardIndexPath(indexPath))
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

}

extension PartDetailTableViewController {

    @IBAction func cancelCrew(segue: UIStoryboardSegue) { }

    @IBAction func saveCrew(segue: UIStoryboardSegue) {
        do {
            try  (segue.sourceViewController as! CrewDetailTableViewController).managedObjectContext?.save()
        } catch {
            let nserror = error as NSError
            NSLog("Couldn't save: \(nserror), \(nserror.userInfo)")
        }
    }

}
