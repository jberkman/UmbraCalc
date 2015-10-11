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

import CoreData
import UIKit

private let nameCellIdentifier = "nameCell"
private let crewCapacityCellIdentifier = "crewCapacityCell"
private let livingSpacesCellIdentifier = "livingSpacesCell"
private let workspacesCellIdentifier = "workspacesCell"

class KolonizedDetailTableViewController: UIViewController {

    private struct Row {
        let reuseIdentifier: String
        let configureCell: (cell: UITableViewCell, indexPath: NSIndexPath) -> Void
    }

    private struct Section {
        let footerTitle: String?
        let rows: [Row]?
        let dataSource: UITableViewDataSource?

        init(footerTitle: String?, rows: [Row]) {
            self.footerTitle = footerTitle
            self.rows = rows
            dataSource = nil
        }

        init(footerTitle: String?, dataSource: UITableViewDataSource) {
            self.footerTitle = footerTitle
            self.dataSource = dataSource
            rows = nil
        }
    }

    private lazy var sections: [Section] = [
        Section(footerTitle: nil, rows: [
            Row(reuseIdentifier: nameCellIdentifier) { [weak self] cell, _ in
                guard let textField = cell.contentView.subviews.first as? UITextField else { return }
                textField.text = self?.namedEntity?.name
                textField.delegate = self
            }
            ]),

        Section(footerTitle: "Activating converters slightly reduces crew efficiency of this station or kolony.\n\n" +
            "IMPORTANT: Resource converters on efficiency parts should be deactivated when used as efficiency parts.",
            dataSource: self.kolonizedDataSource),

        Section(footerTitle: "Crew efficiency is improved by adding workspaces and living spaces, and having at least five crewmembers on the station or kolony.", rows: [
            Row(reuseIdentifier: crewCapacityCellIdentifier) { [weak self] cell, _ in
                cell.detailTextLabel!.text = String(self?.kolonizingCollection?.crewCapacity ?? 0)
            },
            Row(reuseIdentifier: livingSpacesCellIdentifier) { [weak self] cell, _ in
                cell.detailTextLabel!.text = String(self?.kolonizingCollection?.livingSpaceCount ?? 0)
            },
            Row(reuseIdentifier: workspacesCellIdentifier) { [weak self] cell, _ in
                cell.detailTextLabel!.text = String(self?.kolonizingCollection?.workspaceCount ?? 0)
            }
            ])
    ]

    private func indexPathForRowWithReuseIdentifier(reuseIdentifier: String) -> NSIndexPath? {
        for (sectionIndex, section) in sections.enumerate() {
            guard let rows = section.rows else { continue }
            for (rowIndex, row) in rows.enumerate() {
                if row.reuseIdentifier == reuseIdentifier {
                    return NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
                }
            }
        }
        return nil
    }

    @IBOutlet weak var resupplyStackView: UIStackView!
    @IBOutlet weak var tableView: UITableView!

    private var hasAppeared = false

    private lazy var dataSource: StoryboardDelegatedDataSource = StoryboardDelegatedDataSource(dataSource: self)
    private lazy var kolonizedDataSource: KolonizedDataSource = KolonizedDataSource(sectionOffset: 1)

    private var nameTextField: UITextField? {
        guard let indexPath = indexPathForRowWithReuseIdentifier(nameCellIdentifier) else { return nil }
        return tableView.cellForRowAtIndexPath(indexPath)?.contentView.subviews.first as? UITextField
    }

    var namedEntity: NamedEntity? {
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
        dataSource.registerDataSource(kolonizedDataSource)

        tableView.dataSource = dataSource
        tableView.delegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        if kolonizedDataSource.fetchedResultsController == nil {
            kolonizedDataSource.reloadData()
        }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            crewDetail.crew = kolonizedDataSource.modelAtIndexPath(indexPath) as? Crew

        case Part.addSegueIdentifier:
            let filteredOutKeyword = station == nil ? "orbital" : "surface"
            let navigationController = segue.destinationViewController as! UINavigationController
            let partNodeList = navigationController.viewControllers.first as! PartNodeListTableViewController
            partNodeList.partNodes = partNodeList.partNodes.filter { !$0.title.lowercaseString.containsString(filteredOutKeyword) }

            guard let indexPath = tableView.indexPathForSegueSender(sender),
                base = kolonizedDataSource.modelAtIndexPath(indexPath) as? Base else {
                    selectedBase = nil
                    break
            }
            selectedBase = base

        case Part.showSegueIdentifier:
            let indexPath = tableView.indexPathForSegueSender(sender)!
            let partDetail = segue.destinationViewController as! PartDetailTableViewController
            partDetail.part = kolonizedDataSource.modelAtIndexPath(indexPath) as? Part

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

        tableView.indexPathsForVisibleRows?.forEach {
            guard $0 != indexPath, let cell = tableView.cellForRowAtIndexPath($0) else { return }
            guard let dataSource = sections[$0.section].dataSource else {
                sections[$0.section].rows![$0.row].configureCell(cell: cell, indexPath: $0)
                return
            }
            guard let dataSource2 = dataSource as? KolonizedDataSource else {
                tableView.reloadRowsAtIndexPaths([$0], withRowAnimation: .Fade)
                return
            }
            dataSource2.configureCell(cell, forModel: dataSource2.modelAtIndexPath($0))
        }

        UIView.animateWithDuration(0.2) {
            self.resupplyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.kolonizingCollection?.netResourceConversion
                .filter { $0.1 < 0 }
                .map {
                    let label = UILabel()
                    label.text = "\($0.0): \(-$0.1 * secondsPerYear)"
                    return label
                }
                .forEach { self.resupplyStackView.addArrangedSubview($0) }
            self.resupplyStackView.hidden = self.resupplyStackView.arrangedSubviews.isEmpty
        }
    }

}

extension KolonizedDetailTableViewController: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows?.count ?? sections[section].dataSource!.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let row = sections[indexPath.section].rows?[indexPath.row] else {
            return sections[indexPath.section].dataSource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(row.reuseIdentifier, forIndexPath: indexPath)
        row.configureCell(cell: cell, indexPath: indexPath)
        return cell
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footerTitle
    }

}

extension KolonizedDetailTableViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        alert.addAction(UIAlertAction(title: "Add Part", style: .Default) { _ in
            self.performSegueWithIdentifier(Part.addSegueIdentifier, sender: indexPath)
            })

        alert.addAction(UIAlertAction(title: "Edit Name", style: .Default) { _ in
            let alert = UIAlertController(title: "Rename Base", message: nil, preferredStyle: .Alert)
            let base = self.kolonizedDataSource.modelAtIndexPath(indexPath) as! Base

            alert.addTextFieldWithConfigurationHandler {
                $0.text = base.name
            }

            alert.addAction(UIAlertAction(title: "Save", style: .Default) { _ in
                base.name = alert.textFields![0].text
                })

            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

            self.presentViewController(alert, animated: true, completion: nil)
            })

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        alert.popoverPresentationController?.sourceView = cell
        alert.popoverPresentationController?.sourceRect = cell.bounds
        alert.popoverPresentationController?.permittedArrowDirections = [.Up, .Down]

        presentViewController(alert, animated: true, completion: nil)
    }

    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard indexPath.section == kolonizedDataSource.sectionOffset else { return false }
        let model = kolonizedDataSource.modelAtIndexPath(indexPath)
        return model is Crew || (model as? Part)?.crewed == true
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == kolonizedDataSource.sectionOffset else { return }
        let identifier = (kolonizedDataSource.modelAtIndexPath(indexPath) as! Segueable).showSegueIdentifier
        performSegueWithIdentifier(identifier, sender: indexPath)
    }

    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        guard indexPath.section == kolonizedDataSource.sectionOffset else { return 0 }
        return kolonizedDataSource.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == kolonizedDataSource.sectionOffset
    }

}

extension KolonizedDetailTableViewController: KolonizedDataSourceDelegate {

    func tableView(tableView: UITableView, stepperAccessory: UIStepper, valueChangedForRowAtIndexPath indexPath: NSIndexPath) {
        let model = kolonizedDataSource.modelAtIndexPath(indexPath)
        if let part = model as? Part {
            part.count = Int16(stepperAccessory.value)
            (part.resourceConverters as? Set<ResourceConverter>)?.forEach { $0.activeCount = min($0.activeCount, part.count) }
        } else if let resourceConverter = model as? ResourceConverter {
            resourceConverter.activeCount = Int16(stepperAccessory.value)
        }
        updateView(exceptRowAtIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, switchAccessory: UISwitch, valueChangedForRowAtIndexPath indexPath: NSIndexPath) {
        (kolonizedDataSource.modelAtIndexPath(indexPath) as! ResourceConverter).activeCount = switchAccessory.on ? 1 : 0
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
        _ = try? Base(insertIntoManagedObjectContext: managedObjectContext).withKolony(kolony) //.withDefaultParts()
    }

    @IBAction func cancelPart(segue: UIStoryboardSegue) {
        selectedBase = nil
    }

    private func addPartNodeToCurrentVessel(partNode: PartNode) {
        if partNode.crewCapacity == 0, let existingPart = (currentVessel?.parts as? Set<Part>)?.lazy.filter({ $0.partName == partNode.name }).first {
            ++existingPart.count
            return
        }

        guard let managedObjectContext = currentVessel?.managedObjectContext else { return }
        _ = try? Part(insertIntoManagedObjectContext: managedObjectContext).withPartName(partNode.name).withVessel(currentVessel!)

        guard let indexPaths = tableView.indexPathsForVisibleRows else { return }
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }

    @IBAction func savePart(segue: UIStoryboardSegue) {
        let partNodeList = segue.sourceViewController as! PartNodeListTableViewController
        if let partNode = partNodeList.selectedPartNode {
            addPartNodeToCurrentVessel(partNode)
        }
        selectedBase = nil
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
