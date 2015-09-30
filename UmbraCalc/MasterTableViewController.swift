//
//  MasterTableViewController.swift
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

class MasterTableViewController: ManagedTableViewController {

    @IBOutlet weak var entitySegmentedControl: UISegmentedControl?
    @IBOutlet weak var addButton: UIBarButtonItem?

    var splitAccessoryType: UITableViewCellAccessoryType {
        return splitViewController?.delegate === self && splitViewController?.collapsed == false ? .None : .DisclosureIndicator
    }

    override var selectedObject: Entity? {
        didSet {
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if selectedObject != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteEntityWithNotification:", name: willDeleteEntityNotification, object: selectedObject!)
            }
        }
    }

    var emptyDetailViewController: UIViewController? {
        return storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController")
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
        displayedEntityName = Kolony.segueTypeNoun
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateDetailView()

        let accessoryType = splitAccessoryType
        clearsSelectionOnViewWillAppear = splitViewController?.delegate === self || splitViewController?.collapsed != false
        tableView.visibleCells.forEach {
            $0.accessoryType = accessoryType
            $0.editingAccessoryType = accessoryType
        }
    }

    private func updateDetailView() {
        guard splitViewController?.delegate === self && splitViewController?.collapsed == false && tableView.indexPathForSelectedRow == nil else { return }
        guard tableView.numberOfRowsInSection(0) > 0 else {
            guard let viewController = emptyDetailViewController else { return }
            showDetailViewController(viewController, sender: self)
            return
        }
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.setLeftBarButtonItem(editing || navigationController?.viewControllers.first == self ? addButton : nil, animated: animated)
    }

    override func managedDataSource<Entity, Cell>(managedDataSource: ManagedDataSource<Entity, Cell>, configureCell cell: Cell, forEntity entity: Entity) {
        super.managedDataSource(managedDataSource, configureCell: cell, forEntity: entity)
        let accessoryType = splitAccessoryType
        cell.accessoryType = accessoryType
        cell.editingAccessoryType = accessoryType
    }

    @IBAction func segmentDidChange(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: displayedEntityName = Kolony.segueTypeNoun
        case 1: displayedEntityName = Station.segueTypeNoun
        case 2: displayedEntityName = Crew.segueTypeNoun
        default: break
        }
    }

    @objc private func willDeleteEntityWithNotification(notification: NSNotification) {
        guard splitViewController?.collapsed == false else {
            selectedObject = nil
            return
        }

        guard let entity = dataSource.entities?.lazy.filter({ $0 != self.selectedObject }).first,
            indexPath = dataSource.indexPathOfEntity(entity) else {
                selectedObject = nil
                guard let viewController = emptyDetailViewController else { return }
                showDetailViewController(viewController, sender: self)
                return
        }

        performSegueWithIdentifier(displayedEntityName.showSegueIdentifier, sender: indexPath)
        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    }

}

extension MasterTableViewController: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        return emptyDetailViewController
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return secondaryViewController is EmptyDetailViewController
    }

}
