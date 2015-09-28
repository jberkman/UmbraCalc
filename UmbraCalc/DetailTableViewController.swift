//
//  DetailTableViewController.swift
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

class DetailTableViewController: UITableViewController, ManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext?

    var ignoreContextChanges = false

    func withIgnoredChanges(@noescape body: () -> Void) {
        let oldValue = ignoreContextChanges
        ignoreContextChanges = true
        body()
        ignoreContextChanges = oldValue
    }

    func contextDidChange(context: UnsafeMutablePointer<Void>) -> Bool {
        return false
    }

    func observerContextDidChange(context: ObserverContext) -> Bool {
        return contextDidChange(&context.context)
    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard !contextDidChange(context) else { return }
        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
    }


    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

}
