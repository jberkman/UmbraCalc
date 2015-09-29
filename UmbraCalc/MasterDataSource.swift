//
//  MasterDataSource.swift
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

protocol MasterDataSourceDelegate: ManagedDataSourceDelegate {

    func masterDataSource<Entity, Cell>(masterDataSource: MasterDataSource<Entity, Cell>, showDetailViewControllerForRowAtIndexPath indexPath: NSIndexPath)

}

class MasterDataSource<Entity: NSManagedObject, Cell: UITableViewCell>: ManagedDataSource<Entity, Cell> {

    var tableViewController: UITableViewController? {
        didSet {
            tableView = tableViewController?.tableView
        }
    }

    weak var masterDelegate: MasterDataSourceDelegate? {
        didSet {
            delegate = masterDelegate
        }
    }

    var selectedEntity: Entity? {
        didSet {
            if oldValue != nil {
                NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: oldValue!)
            }
            if selectedEntity != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "willDeleteEntityWithNotification:", name: willDeleteEntityNotification, object: selectedEntity!)
            }
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: willDeleteEntityNotification, object: nil)
    }

    @objc private func willDeleteEntityWithNotification(notification: NSNotification) {
        guard tableViewController?.splitViewController?.collapsed == false else {
            selectedEntity = nil
            return
        }

        guard let entity = entities?.lazy.filter({ $0 != self.selectedEntity }).first,
            indexPath = indexPathOfEntity(entity) else {
                selectedEntity = nil
                guard let empty = tableViewController?.storyboard?.instantiateViewControllerWithIdentifier("emptyDetailViewController") else { return }
                tableViewController?.showDetailViewController(empty, sender: self)
                return
        }

        masterDelegate?.masterDataSource(self, showDetailViewControllerForRowAtIndexPath: indexPath)
    }

}
