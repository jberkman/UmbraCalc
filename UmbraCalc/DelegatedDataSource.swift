//
//  DelegatedDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-06.
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

class DelegatedDataSource: NSObject {

    private let rootDataSource: UITableViewDataSource
    private var dataSources = [Int: UITableViewDataSource]()

    init(dataSource: UITableViewDataSource) {
        rootDataSource = dataSource
        super.init()
    }

    func registerDataSource(dataSource: UITableViewDataSource, forSection section: Int) {
        dataSources[section] = dataSource
    }

    func unregisterDataSourceForSection(section: Int) {
        dataSources[section] = nil
    }

    func registerDataSource(dataSource: OffsettableDataSource) {
        registerDataSource(dataSource, forSection: dataSource.sectionOffset)
    }

    func unregisterDataSource(dataSource: OffsettableDataSource) {
        unregisterDataSourceForSection(dataSource.sectionOffset)
    }

    private func tableView(tableView: UITableView, dataSourceForSection section: Int) -> UITableViewDataSource {
        let rootSections = rootDataSource.numberOfSectionsInTableView?(tableView) ?? 1
        return section < rootSections ? (dataSources[section] ?? rootDataSource) : dataSources[rootSections - 1]!
    }

}

extension DelegatedDataSource: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = self.tableView(tableView, dataSourceForSection: section)
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        return dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let numberOfSections = rootDataSource.numberOfSectionsInTableView?(tableView) ?? 1
        let dataSource = self.tableView(tableView, dataSourceForSection: numberOfSections - 1)
        return dataSource.numberOfSectionsInTableView?(tableView) ?? 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dataSource = self.tableView(tableView, dataSourceForSection: section)
        return dataSource.tableView?(tableView, titleForHeaderInSection: section)
    }

    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let dataSource = self.tableView(tableView, dataSourceForSection: section)
        return dataSource.tableView?(tableView, titleForFooterInSection: section)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        return dataSource.tableView?(tableView, canEditRowAtIndexPath: indexPath) ?? true
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        return dataSource.tableView?(tableView, canMoveRowAtIndexPath: indexPath) ?? dataSource.respondsToSelector("tableView:moveRowAtIndexPath:toIndexPath:")
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return rootDataSource.sectionIndexTitlesForTableView?(tableView)
    }

    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return rootDataSource.tableView!(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let dataSource = self.tableView(tableView, dataSourceForSection: indexPath.section)
        dataSource.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let dataSource = self.tableView(tableView, dataSourceForSection: sourceIndexPath.section)
        dataSource.tableView?(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }

}

class StoryboardDelegatedDataSource: DelegatedDataSource {

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return rootDataSource.tableView?(tableView, titleForHeaderInSection: section)
    }

    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return rootDataSource.tableView?(tableView, titleForFooterInSection: section)
    }

}
