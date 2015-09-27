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

class MasterTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem?

    var currentAccessoryType: UITableViewCellAccessoryType {
        return splitViewController?.collapsed == false ? .None : .DisclosureIndicator
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateVisibleAccessoryTypes()
        updateDetailView()
    }

    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateVisibleAccessoryTypes()
        updateDetailView()
    }

    private func updateDetailView() {
        guard splitViewController?.collapsed == false && tableView.indexPathForSelectedRow == nil else { return }
        guard tableView.numberOfRowsInSection(0) > 0 else {
            guard let emptyDetailViewController = storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController") else { return }
            showDetailViewController(emptyDetailViewController, sender: self)
            return
        }
        showDetailViewControllerForEntityAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))
    }

    private func updateVisibleAccessoryTypes() {
        let accessoryType = currentAccessoryType
        tableView.visibleCells.forEach {
            $0.accessoryType = accessoryType
            $0.editingAccessoryType = accessoryType
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        navigationItem.setLeftBarButtonItem(editing || navigationController?.viewControllers.first == self ? addButton : nil, animated: animated)
    }

    func showDetailViewControllerForEntityAtIndexPath(indexPath: NSIndexPath) {
        fatalError("\(__FUNCTION__): not implemented")
    }

}

extension MasterTableViewController: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        return storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController")
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        return secondaryViewController is EmptyDetailViewController
    }

}
