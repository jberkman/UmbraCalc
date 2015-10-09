//
//  CrewSelectionDataSource.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-09.
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

class CrewSelectionDataSource: SelectionDataSource<Crew, UITableViewCell> {

    var part: Part? {
        didSet {
            maximumSelectionCount = part?.crewCapacity ?? Int.max
            managedObjectContext = part?.managedObjectContext
        }
    }

    override var selectedModels: Set<CrewSelectionDataSource.Model> {
        get { return part?.crew as? Set<Crew> ?? Set() }
        set { part?.crew = newValue }
    }

    override init(sectionOffset: Int = 0) {
        super.init(sectionOffset: sectionOffset)
    }

    override func configureCell(cell: CrewSelectionDataSource.Cell, forModel model: CrewSelectionDataSource.Model) {
        super.configureCell(cell, forModel: model)
        cell.textLabel?.text = model.crewDisplayName
        cell.detailTextLabel?.text = model.career
    }

    override func selectModel(model: Model) {
        model.part = part
    }

    override func deselectModel(model: Model) {
        model.part = nil
    }

}