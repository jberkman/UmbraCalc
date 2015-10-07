//
//  KolonyDetailTableViewController.swift
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

class KolonyDetailTableViewController: UITableViewController {

    private class BaseDataSource: FetchedDataSource<Base, UITableViewCell> {

        var kolony: Kolony? {
            didSet {
                managedObjectContext = kolony?.managedObjectContext
                fetchRequest.predicate = kolony == nil ? nil : NSPredicate(format: "kolony = %@", kolony!)
            }
        }

        private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

        override init(sectionOffset: Int) {
            super.init(sectionOffset: sectionOffset)
            reuseIdentifier = "baseCell"
            fetchRequest.sortDescriptors = [Kolony.nameSortDescriptor]
        }

        private override func configureCell(cell: BaseDataSource.Cell, forModel model: BaseDataSource.Model) {
            cell.textLabel?.text = model.displayName
            cell.detailTextLabel?.text = "\(model.crewCount) of \(model.crewCapacity) Crew, \(percentFormatter.stringFromNumber(model.crewHappiness)!) Happiness"
            cell.accessoryType = .DisclosureIndicator
        }
    }

    private class CrewDataSource: FetchedDataSource<Crew, UITableViewCell> {

        var kolony: Kolony? {
            didSet {
                managedObjectContext = kolony?.managedObjectContext
                fetchRequest.predicate = kolony == nil ? nil : NSPredicate(format: "part.vessel.kolony == %@", kolony!)
            }
        }

        override init(sectionOffset: Int = 0) {
            super.init(sectionOffset: sectionOffset)
            reuseIdentifier = "crewCell"
            fetchRequest.sortDescriptors = [Crew.nameSortDescriptor]
        }

        override func configureCell(cell: UITableViewCell, forModel crew: Crew) {
            cell.textLabel?.text = crew.displayName
            cell.detailTextLabel?.text = crew.part?.vessel?.displayName
            cell.selectionStyle = .None
        }
        
    }
    
    @IBOutlet weak var crewCapacityLabel: UILabel!
    @IBOutlet weak var livingSpacesLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var workspacesLabel: UILabel!

    private var hasAppeared = false

    private lazy var dataSource: StoryboardDelegatedDataSource = StoryboardDelegatedDataSource(dataSource: self)
    private lazy var baseDataSource = BaseDataSource(sectionOffset: 1)
    private lazy var crewDataSource = CrewDataSource(sectionOffset: 2)

    var kolony: Kolony? {
        didSet {
            baseDataSource.kolony = kolony
            crewDataSource.kolony = kolony
            updateView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SubtitleTableViewCell.self, forCellReuseIdentifier: baseDataSource.reuseIdentifier)
        dataSource.registerDataSource(baseDataSource)
        baseDataSource.tableView = tableView

        tableView.registerClass(Value1TableViewCell.self, forCellReuseIdentifier: crewDataSource.reuseIdentifier)
        dataSource.registerDataSource(crewDataSource)
        crewDataSource.tableView = tableView

        tableView.dataSource = dataSource
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateView()
        if baseDataSource.fetchedResultsController == nil {
            baseDataSource.reloadData()
        }
        if crewDataSource.fetchedResultsController == nil {
            crewDataSource.reloadData()
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasAppeared else { return }
        hasAppeared = true
        guard kolony?.name?.isEmpty != false else { return }
        nameTextField.becomeFirstResponder()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Base.addSegueIdentifier:
            guard let managedObjectContext = baseDataSource.managedObjectContext where kolony != nil else { return }
            let baseDetail = segue.destinationViewController as! VesselDetailTableViewController
            baseDetail.vessel = try? Base(insertIntoManagedObjectContext: managedObjectContext).withKolony(kolony) //.withDefaultParts()

        case Base.showSegueIdentifier:
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)!
            let vesselDetail = segue.destinationViewController as! VesselDetailTableViewController
            vesselDetail.vessel = baseDataSource.modelAtIndexPath(indexPath)

        default:
            break
        }
    }

    private func updateView() {
        guard isViewLoaded() else { return }

        nameTextField.text = kolony?.name

        crewCapacityLabel.text = String(kolony?.crewCapacity ?? 0)
        livingSpacesLabel.text = String(kolony?.livingSpaceCount ?? 0)
        workspacesLabel.text = String(kolony?.workspaceCount ?? 0)
    }

}

extension KolonyDetailTableViewController {

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case baseDataSource.sectionOffset:
            performSegueWithIdentifier(Base.showSegueIdentifier, sender: tableView.cellForRowAtIndexPath(indexPath))

        default:
            break
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case baseDataSource.sectionOffset, crewDataSource.sectionOffset:
            return 44

        default:
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return 0 // super.tableView(tableView, indentationLevelForRowAtIndexPath: storyboardIndexPath(indexPath))
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == baseDataSource.sectionOffset
    }

}

extension KolonyDetailTableViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(textField: UITextField) {
        kolony?.name = textField.text
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

}
