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

class KolonizedDetailTableViewController: UITableViewController {

    @IBOutlet weak var crewCapacityLabel: UILabel!
    @IBOutlet weak var livingSpacesLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var workspacesLabel: UILabel!

    private var hasAppeared = false

    private lazy var dataSource: StoryboardDelegatedDataSource = StoryboardDelegatedDataSource(dataSource: self)
    private lazy var kolonizedDataSource: KolonizedDataSource = KolonizedDataSource(sectionOffset: 1)

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

        kolonizedDataSource.tableView = tableView
        dataSource.registerDataSource(kolonizedDataSource)

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        if kolonizedDataSource.fetchedResultsController == nil {
            kolonizedDataSource.reloadData()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        guard namedEntity?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
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
        nameTextField.text = namedEntity?.name

        crewCapacityLabel.text = String(kolonizingCollection?.crewCapacity ?? 0)
        livingSpacesLabel.text = String(kolonizingCollection?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(kolonizingCollection?.workspaceCount ?? 0)

        tableView.indexPathsForVisibleRows?.forEach {
            guard $0.section == kolonizedDataSource.sectionOffset && $0 != indexPath,
                let cell = tableView.cellForRowAtIndexPath($0) else { return }
            kolonizedDataSource.configureCell(cell, forModel: kolonizedDataSource.modelAtIndexPath($0))
        }

        kolonizingCollection?.logResources()
    }

}

extension KolonizedDetailTableViewController {

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
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

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard indexPath.section == kolonizedDataSource.sectionOffset else { return false }
        let model = kolonizedDataSource.modelAtIndexPath(indexPath)
        return model is Crew || (model as? Part)?.crewed == true
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard indexPath.section == kolonizedDataSource.sectionOffset else { return }
        let identifier = (kolonizedDataSource.modelAtIndexPath(indexPath) as! Segueable).showSegueIdentifier
        performSegueWithIdentifier(identifier, sender: indexPath)
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case kolonizedDataSource.sectionOffset:
            return 44

        default:
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        guard indexPath.section == kolonizedDataSource.sectionOffset else { return 0 }
        return kolonizedDataSource.tableView(tableView, indentationLevelForRowAtIndexPath: indexPath)
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
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
