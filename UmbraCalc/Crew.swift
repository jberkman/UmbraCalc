//
//  Crew.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-23.
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

class Crew: NamedEntity {

    static let engineerTitle = "Engineer"
    static let scientistTitle = "Scientist"
    static let pilotTitle = "Pilot"

    var starString: String {
        return String(count: Int(starCount), repeatedValue: "⭐️")
    }

    func withCareer(career: String) -> Self {
        return withValue(career, forKey: "career")
    }

    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

    func withPart(part: Part?) -> Self {
        return withValue(part, forKey: "part")
    }

    func withStarCount(starCount: Int) -> Self {
        return withValue(starCount, forKey: "starCount")
    }

}

extension Crew: ModelNaming, SegueableType, Segueable {
    class var modelName: String { return "Crew" }
}

extension FetchableDataSource {

    func configureCell(cell: Cell, forCrew crew: Crew) {
        cell.textLabel?.text = (crew.name ?? "") + String(count: Int(crew.starCount), repeatedValue: "⭐️")
    }

}
