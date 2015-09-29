//
//  CrewFetchedDataSource.swift
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

import UIKit

extension FetchedDataSource where Entity: Crew {

    func configureCell(cell: Cell, crew: Entity) {
        let starString = String(count: Int(crew.starCount), repeatedValue: "⭐️")
        if let career = crew.career {
            cell.detailTextLabel?.text = "\(career) \(starString)"
        } else {
            cell.detailTextLabel?.text = starString.isEmpty ? "0 Stars" : starString
        }
    }

}
