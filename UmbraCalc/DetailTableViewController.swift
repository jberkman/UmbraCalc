//
//  DetailTableViewController.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
//  Copyright © 2015 jacob berkman. All rights reserved.
//

import CoreData
import UIKit

class DetailTableViewController: UITableViewController, ManagingObjectContext {

    var managedObjectContext: NSManagedObjectContext?

    var ignoreContextChanges = false

    private func withIgnoredChanges(@noescape block: () -> Void) {
        let oldValue = ignoreContextChanges
        ignoreContextChanges = true
        block()
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
