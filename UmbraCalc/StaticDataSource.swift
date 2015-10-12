//
//  StaticDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-11.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import Foundation
import UIKit

struct Row {
    let reuseIdentifier: String
    let configureCell: (cell: UITableViewCell, indexPath: NSIndexPath) -> Void
}

struct Section {
    let rows: [Row]
    let headerTitle: String?
    let footerTitle: String?

    subscript (row: Int) -> Row { return rows[row] }
}

class StaticDataSource: NSObject {

    private let sections: [Section]

    init(sections: [Section]) {
        self.sections = sections
    }

    subscript (section: Int) -> Section { return sections[section] }
    subscript (indexPath: NSIndexPath) -> Row { return self[indexPath.section][indexPath.row] }

    func indexPathForRowWithReuseIdentifier(reuseIdentifier: String) -> NSIndexPath? {
        for (sectionIndex, section) in sections.enumerate() {
            for (rowIndex, row) in section.rows.enumerate() {
                guard row.reuseIdentifier == reuseIdentifier else { continue }
                return NSIndexPath(forRow: rowIndex, inSection: sectionIndex)
            }
        }
        return nil
    }

}

extension StaticDataSource: UITableViewDataSource {

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[section].rows.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self[indexPath].reuseIdentifier, forIndexPath: indexPath)
        self[indexPath].configureCell(cell: cell, indexPath: indexPath)
        return cell
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self[section].headerTitle
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self[section].footerTitle
    }

}
