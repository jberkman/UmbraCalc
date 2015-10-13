//
//  CrewDataSource.swift
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

import JeSuis
import Foundation
import UIKit

class CrewDataSource: FetchedDataSource<Crew, UITableViewCell> {

    enum DetailType {
        case Career
        case Part
        case Vessel
    }

    var detailType = DetailType.Career
    var selectable = false

    override init(sectionOffset: Int = 0) {
        super.init(sectionOffset: sectionOffset)
        reuseIdentifier = "crewCell"
        fetchRequest.sortDescriptors = [Crew.nameSortDescriptor]
    }

    override func configureCell(cell: UITableViewCell, forElement crew: Crew) {
        cell.textLabel?.text = crew.crewDisplayName
        cell.detailTextLabel?.text = {
            switch self.detailType {
            case .Career: return crew.career
            case .Part: return crew.part?.displayName
            case .Vessel: return crew.part?.vessel?.displayName
            }
            }()
        cell.selectionStyle = selectable ? .Default : .None
        cell.accessoryType = selectable ? .DisclosureIndicator : .None
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard editingStyle == .Delete else { return }
        self[indexPath].deleteEntity()
    }

}
