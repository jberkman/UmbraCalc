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

    private class ResourceConverterDataSource: FetchedDataSource<ResourceConverter, UITableViewCell> {

        private var part: Part? {
            didSet {
                managedObjectContext = part?.managedObjectContext
                fetchRequest.predicate = part == nil ? nil : NSPredicate(format: "part = %@", part!)
            }
        }

        override init(sectionOffset: Int = 0) {
            super.init(sectionOffset: sectionOffset)
            reuseIdentifier = "resourceConverterCell"
            fetchRequest.sortDescriptors = [ResourceConverter.nameSortDescriptor]
        }

        private func textLabelForModel(model: ResourceConverterDataSource.Model) -> String? {
            guard model.part?.crewCapacity == 0 else { return model.name }
            let capacity = model.part?.count ?? 0
            return "\(model.displayName) (\(model.activeCount) of \(capacity))"
        }

        private override func configureCell(cell: ResourceConverterDataSource.Cell, forModel resourceConverter: Model) {
            cell.textLabel?.text = textLabelForModel(resourceConverter)

            let inputs = resourceConverter.inputResources.keys.sort().joinWithSeparator(" + ")
            let outputs = resourceConverter.outputResources.keys.sort().joinWithSeparator(" + ")
            cell.detailTextLabel?.text = "\(inputs) -> \(outputs)"

            if resourceConverter.part?.crewCapacity > 0 {
                if !(cell.accessoryView is UISwitch) {
                    let toggle = UISwitch()
                    toggle.addTarget(self, action: "toggleDidChangeValue:", forControlEvents: .ValueChanged)
                    cell.accessoryView = toggle
                }
                (cell.accessoryView as! UISwitch).on = resourceConverter.activeCount > 0
            } else {
                if !(cell.accessoryView is UIStepper) {
                    let stepper = UIStepper()
                    stepper.addTarget(self, action: "stepperDidChangeValue:", forControlEvents: .ValueChanged)
                    cell.accessoryView = stepper
                }
                let stepper = cell.accessoryView as! UIStepper
                stepper.value = Double(resourceConverter.activeCount)
                stepper.maximumValue = Double(resourceConverter.part?.count ?? 0)
            }

            cell.selectionStyle = .None
        }

        private func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            return "Activating converters slightly reduces crew efficiency of this station or kolony."
        }

        @objc private func toggleDidChangeValue(sender: UISwitch) {
            guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
            modelAtIndexPath(indexPath).activeCount = sender.on ? 1 : 0
        }

        @objc private func stepperDidChangeValue(sender: UIStepper) {
            guard let indexPath = tableView.indexPathForCellSubview(sender) else { return }
            let resourceConverter = modelAtIndexPath(indexPath)
            resourceConverter.activeCount = Int16(sender.value)
            tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text = textLabelForModel(resourceConverter)
        }
        
    }

    private class EfficiencyPartDataSource: NSObject, OffsettableDataSource {

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

        lazy var partNodes: [PartNode] = bundledPartNodes

        var reuseIdentifier = "efficiencyPartCell"
        let sectionOffset: Int

        private var part: Part? {
            didSet {
                partNodes = EfficiencyPartDataSource.bundledPartNodes.filter { self.part?.efficiencyParts[$0.name] != nil }
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
            guard let vesselEfficiencyParts = part?.vessel?.efficiencyParts,
                rate = part?.efficiencyParts[partNode.name],
                rateString = percentFormatter.stringFromNumber(rate) else { return cell }
            let count = vesselEfficiencyParts.map { $0.partName == partNode.name ? $0.count : 0 }.reduce(0, combine: +)
            cell.detailTextLabel?.text = "\(count) x \(rateString)"
            return cell
        }

    }

    @IBOutlet weak var careerFactorLabel: UILabel!
    @IBOutlet weak var crewCell: UITableViewCell!
    @IBOutlet weak var crewEfficiencyLabel: UILabel!
    @IBOutlet weak var efficiencyLabel: UILabel!
    @IBOutlet weak var livingSpaceCountLabel: UILabel!
    @IBOutlet weak var partsEfficiencyLabel: UILabel!
    @IBOutlet weak var workspaceCountLabel: UILabel!

    private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

    private lazy var dataSource: StoryboardDelegatedDataSource = StoryboardDelegatedDataSource(dataSource: self)
    private lazy var resourceConverterDataSource = ResourceConverterDataSource(sectionOffset: 1)
    private lazy var efficiencyPartDataSource = EfficiencyPartDataSource(sectionOffset: 4)

    var part: Part? {
        didSet {
            resourceConverterDataSource.part = part
            efficiencyPartDataSource.part = part
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerClass(SubtitleTableViewCell.self, forCellReuseIdentifier: resourceConverterDataSource.reuseIdentifier)
        dataSource.registerDataSource(resourceConverterDataSource)
        resourceConverterDataSource.tableView = tableView

        tableView.registerClass(Value1TableViewCell.self, forCellReuseIdentifier: efficiencyPartDataSource.reuseIdentifier)
        dataSource.registerDataSource(efficiencyPartDataSource)

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        if resourceConverterDataSource.fetchedResultsController == nil {
            resourceConverterDataSource.reloadData()
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.showListSegueIdentifier:
            (segue.destinationViewController as! CrewSelectionTableViewController).part = part

        default:
            break
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        switch identifier {
        case Crew.showListSegueIdentifier:
            return part?.crewCapacity > 0

        default:
            return true
        }
    }

    private func updateView() {
        guard isViewLoaded() else { return }
        navigationItem.title = part?.title

        let crewCount = part?.crew?.count ?? 0
        let crewCapacity = part?.crewCapacity ?? 0
        crewCell.detailTextLabel?.text = crewCapacity > 0 ? "\(crewCount) of \(crewCapacity)" : "Uncrewed"
        crewCell.accessoryType = crewCapacity > 0 ? .DisclosureIndicator : .None
        crewCell.selectionStyle = crewCapacity > 0 ? .Default : .None

        livingSpaceCountLabel.text = String(part?.livingSpaceCount ?? 0)
        workspaceCountLabel.text = String(part?.workspaceCount ?? 0)
        careerFactorLabel.text = percentFormatter.stringFromNumber(part?.crewCareerFactor ?? 0)
        crewEfficiencyLabel.text = percentFormatter.stringFromNumber(part?.crewEfficiency ?? 0)
        partsEfficiencyLabel.text = percentFormatter.stringFromNumber(part?.partsEfficiency ?? 0)
        efficiencyLabel.text = percentFormatter.stringFromNumber(part?.efficiency ?? 0)
    }

}

extension PartDetailTableViewController {

//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        switch indexPath.section {
//        case resource.sectionOffset:
//            performSegueWithIdentifier(Base.showSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))
//
//        default:
//            break
//        }
//    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case resourceConverterDataSource.sectionOffset, efficiencyPartDataSource.sectionOffset:
            return 44

        default:
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0 // super.tableView(tableView, indentationLevelForRowAtIndexPath: storyboardIndexPath(indexPath))
    }

}
