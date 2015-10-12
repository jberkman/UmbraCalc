//
//  ScopedDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-08.
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
import Foundation
import JeSuis
import UIKit

class ScopedDataSource: FetchedDataSource<ScopedEntity, UITableViewCell> {

    private var reuseIdentifiers: [String: String] = [:]

    var rootScope: ScopedEntity? {
        didSet {
            managedObjectContext = rootScope?.managedObjectContext
            fetchRequest.predicate = rootScope == nil ? nil : NSPredicate(format: "rootScope == %@ && self != %@", rootScope!, rootScope!)
        }
    }

    override init(sectionOffset: Int) {
        super.init(sectionOffset: sectionOffset)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "scope", ascending: true), NSSortDescriptor(key: "creationDate", ascending: true)]
        sectionNameKeyPath = "scopeGroup.scope"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let model = self[indexPath]
        guard let entityName = model.entity.name, reuseIdentifier = reuseIdentifiers[entityName] else {
            fatalError("Unknown entity for model: \(model)")
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        configureCell(cell, forElement: model)
        return cell
    }

    func registerCellReuseIdentifier(identifier: String, forEntityName entityName: String) {
        reuseIdentifiers[entityName] = identifier
    }

    func tableView(tableView: UITableView, indentationLevelForRowAtIndexPath indexPath: NSIndexPath) -> Int {
        return self[indexPath].scopeDepth - 1
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

}
