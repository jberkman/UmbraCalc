//
//  KolonizedDetailTableViewController.swift
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

import Apropos
import CoreData
import JeSuis
import UIKit

private let nameCellIdentifier = "nameCell"
private let crewCapacityCellIdentifier = "crewCapacityCell"
private let livingSpacesCellIdentifier = "livingSpacesCell"
private let workspacesCellIdentifier = "workspacesCell"

class KolonizedDetailTableViewController: UITableViewController {

    private class ResupplyDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, SectionOffsetting {

        var sectionOffset: Int
        private var resourceNames: [String] = []

        var resources: [String: Double] = [:] {
            didSet {
                resourceNames = resources.keys.sort()
            }
        }

        init(sectionOffset: Int) {
            self.sectionOffset = sectionOffset
        }

        @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return max(1, resources.count)
        }

        @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            guard !resources.isEmpty else {
                return tableView.dequeueReusableCellWithIdentifier("noneCell", forIndexPath: indexPath)
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("resourceCell", forIndexPath: indexPath)
            cell.textLabel!.text = resourceNames[indexPath.row]
            cell.detailTextLabel!.text = String(resources[resourceNames[indexPath.row]]!)
            return cell
        }

        @objc func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            return "Yearly Resupply Required"
        }

        @objc private func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
            return false
        }

    }

    private var hasAppeared = false

    private lazy var dataSource: CompoundDataSource! = CompoundDataSource(dataSource: self.staticDataSource)

    private lazy var staticDataSource: StaticDataSource = StaticDataSource(sections: [
        Section(rows: [
            Row(reuseIdentifier: nameCellIdentifier) { [weak self] cell, _ in
                guard let textField = cell.contentView.subviews.first as? UITextField else { return }
                textField.text = self?.namedEntity?.name
                textField.delegate = self
            }
            ]),

        Section(rows: [
            Row(reuseIdentifier: crewCapacityCellIdentifier) { [weak self] cell, _ in
                cell.detailTextLabel!.text = "\(self?.kolonizingCollection?.crewCount ?? 0) of \(self?.kolonizingCollection?.crewCapacity ?? 0)"
            },
            Row(reuseIdentifier: livingSpacesCellIdentifier) { [weak self] cell, _ in
                cell.detailTextLabel!.text = String(self?.kolonizingCollection?.livingSpaceCount ?? 0)
            },
            Row(reuseIdentifier: workspacesCellIdentifier) { [weak self] cell, _ in
                cell.detailTextLabel!.text = String(self?.kolonizingCollection?.workspaceCount ?? 0)
            }
            ],
            footerTitle: "Crew efficiency is improved by adding workspaces and living spaces, and having at least five crewmembers on the station or kolony."),

        Section(rows: []), // Resupply
        Section(rows: [])  // Kolonized
        ])

    private lazy var resupplyDataSource = ResupplyDataSource(sectionOffset: 2)
    private lazy var kolonizedDataSource: KolonizedDataSource = KolonizedDataSource(sectionOffset: 3)

    //footerTitle: "Activating converters slightly reduces crew efficiency of this station or kolony.\n\n" +
    //            "IMPORTANT: Resource converters on efficiency parts should be deactivated when used as efficiency parts.",


    private var nameTextField: UITextField? {
        guard let indexPath = staticDataSource.indexPathForRowWithReuseIdentifier(nameCellIdentifier) else { return nil }
        return tableView.cellForRowAtIndexPath(indexPath)?.contentView.subviews.first as? UITextField
    }

    // marking dynamic fixes crash at runtime?!
    dynamic var namedEntity: NamedEntity? {
        get {
            return kolonizedDataSource.rootScope as? NamedEntity
        }
        set {
            kolonizedDataSource.rootScope = newValue
            updateView()
        }
    }

    var kolony: Kolony? {
        return kolonizedDataSource.rootScope as? Kolony
    }

    var station: Station? {
        return kolonizedDataSource.rootScope as? Station
    }

    var kolonizingCollection: KolonizingCollectionType? {
        return kolonizedDataSource.rootScope as? KolonizingCollectionType
    }

    var selectedBase: Base?

    var currentVessel: Vessel? {
        return selectedBase ?? station
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = tableView.backgroundColor

        kolonizedDataSource.tableView = tableView
        dataSource[resupplyDataSource] = resupplyDataSource
        dataSource[kolonizedDataSource] = kolonizedDataSource

        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        guard !hasAppeared else { return }
        kolonizedDataSource.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        guard namedEntity?.name?.isEmpty != false else { return }
        nameTextField?.becomeFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Crew.showSegueIdentifier:
            let indexPath = tableView.indexPathForSegueSender(sender)!
            let crewDetail = segue.destinationViewController as! CrewDetailTableViewController
            crewDetail.crew = kolonizedDataSource[indexPath] as? Crew

        case Part.addSegueIdentifier:
            let filteredOutKeywords = station == nil ? [ "orbital", "oks" ] : [ "surface", "mk-v" ]
            let navigationController = segue.destinationViewController as! UINavigationController
            let partNodeList = navigationController.viewControllers.first as! PartNodeListTableViewController

            partNodeList.partNodes = partNodeList.partNodes.filter {
                let title = $0.title.lowercaseString
                return !filteredOutKeywords.contains { title.containsString($0) }
            }

            guard let indexPath = tableView.indexPathForSegueSender(sender),
                base = kolonizedDataSource[indexPath] as? Base else {
                    selectedBase = nil
                    break
            }
            selectedBase = base

        case Part.showSegueIdentifier:
            let indexPath = tableView.indexPathForSegueSender(sender)!
            let partDetail = segue.destinationViewController as! PartDetailTableViewController
            partDetail.part = kolonizedDataSource[indexPath] as? Part

        case "Resource".showSegueIdentifier:
            let indexPath = tableView.indexPathForSegueSender(sender)!
            let resourceDetail = segue.destinationViewController as! ResourceDetailTableViewController
            resourceDetail.resourceName = resupplyDataSource.resourceNames[indexPath.row]
            resourceDetail.kolonizingCollection = kolonizingCollection

        default:
            break
        }
    }

    private func updateTitle() {
        navigationItem.title = station?.displayName ?? kolony?.displayName
    }

    private func updateView(exceptRowAtIndexPath indexPath: NSIndexPath? = nil) {
        guard isViewLoaded() else { return }

        updateTitle()

        tableView.reloadData()

        resupplyDataSource.resources = kolonizingCollection?.netResourceConversion.reduce([:]) {
            guard $1.1 < 0 && $1.0 != "Plutonium-238" else { return $0 }
            var ret = $0
            ret![$1.0] = -$1.1 * secondsPerYear
            return ret
            } ?? [:]

        tableView.reloadSections(NSIndexSet(index: resupplyDataSource.sectionOffset), withRowAnimation: .None)
    }

}

extension KolonizedDetailTableViewController {

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section >= kolonizedDataSource.sectionOffset
    }

}

// UITableViewDelegate
extension KolonizedDetailTableViewController {

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(title: "Rename Base", message: nil, preferredStyle: .Alert)
        let base = self.kolonizedDataSource[indexPath] as! Base

        alert.addTextFieldWithConfigurationHandler { $0.text = base.name }

        alert.addAction(UIAlertAction(title: "Rename", style: .Default) { _ in
            base.name = alert.textFields![0].text
            })

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        presentViewController(alert, animated: true, completion: nil)
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        guard indexPath.section >= kolonizedDataSource.sectionOffset else { return 0 }
        return kolonizedDataSource.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        guard indexPath.section >= kolonizedDataSource.sectionOffset else { return nil }
        return kolonizedDataSource[indexPath] is Crew ? "Unassign" : "Remove"
    }

}

extension KolonizedDetailTableViewController: KolonizedDataSourceDelegate {

    func tableView(tableView: UITableView, stepperAccessory: UIStepper, valueChangedForRowAtIndexPath indexPath: NSIndexPath) {
        let model = kolonizedDataSource[indexPath]
        if let part = model as? Part {
            part.count = Int16(stepperAccessory.value)
            (part.resourceConverters as? Set<ResourceConverter>)?.forEach { $0.activeCount = min($0.activeCount, part.count) }
        } else if let resourceConverter = model as? ResourceConverter {
            resourceConverter.activeCount = Int16(stepperAccessory.value)
        }
        updateView(exceptRowAtIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, switchAccessory: UISwitch, valueChangedForRowAtIndexPath indexPath: NSIndexPath) {
        (kolonizedDataSource[indexPath] as! ResourceConverter).activeCount = switchAccessory.on ? 1 : 0
        updateView(exceptRowAtIndexPath: indexPath)
    }

}

// Adding Parts
extension KolonizedDetailTableViewController {

    @IBAction func addBaseOrPart(sender: UIBarButtonItem) {
        guard let kolony = kolony, managedObjectContext = kolonizedDataSource.managedObjectContext else {
            performSegueWithIdentifier(Part.addSegueIdentifier, sender: sender)
            return
        }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        (kolony.bases as? Set<Base>)?.forEach { base in
            alert.addAction(UIAlertAction(title: "Add Part(s) to \(base.displayName)", style: .Default) { _ in
                self.selectedBase = base
                self.performSegueWithIdentifier(Part.addSegueIdentifier, sender: self.kolonizedDataSource[base])
            })
        }
        alert.addAction(UIAlertAction(title: "Add Base", style: .Default) { _ in
            _ = try? Base(insertIntoManagedObjectContext: managedObjectContext).withKolony(kolony) //.withDefaultParts()
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.popoverPresentationController?.barButtonItem = sender
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func cancelPart(segue: UIStoryboardSegue) {
        selectedBase = nil
    }

    private func addPartNodeToCurrentVessel(partNode: PartNode) {
        if partNode.crewCapacity == 0, let existingPart = (currentVessel?.parts as? Set<Part>)?.lazy.filter({ $0.partFileName == partNode.fileName }).first {
            ++existingPart.count
            return
        }

        guard let managedObjectContext = currentVessel?.managedObjectContext, fileName = partNode.fileName else { return }
        _ = try? Part(insertIntoManagedObjectContext: managedObjectContext).withVessel(currentVessel!).withPartFileName(fileName)
    }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        let partNodeList = segue.sourceViewController as! PartNodeListTableViewController
        partNodeList.selectedPartNodes.forEach(addPartNodeToCurrentVessel)
        selectedBase = nil
        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
    }

}

extension KolonizedDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        namedEntity?.name = textField.text
        updateTitle()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
