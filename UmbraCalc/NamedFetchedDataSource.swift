//
//  VesselFetchedDataSource.swift
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

extension FetchedDataSource where Entity: NamedEntity {

    var nameSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }

    func configureCell(cell: Cell, namedEntity: Entity) {
        cell.textLabel!.text = namedEntity.name
    }

}

extension FetchedDataSource where Entity: NamedType {

    var nameSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "name", ascending: true)]
    }

    func configureCell(cell: Cell, namedType: Entity) {
        cell.textLabel!.text = namedType.name
    }

}
