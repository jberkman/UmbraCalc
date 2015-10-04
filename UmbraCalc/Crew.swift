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

    var displayName: String {
        return (name?.isEmpty == false ? name! : "Unnamed Crew") + starString
    }

    var starString: String {
        return String(count: Int(starCount), repeatedValue: "⭐️")
    }

    @warn_unused_result
    func withCareer(career: String) -> Self {
        return withValue(career, forKey: "career")
    }

    @warn_unused_result
    func withName(name: String) -> Self {
        return withValue(name, forKey: "name")
    }

    @warn_unused_result
    func withPart(part: Part?) -> Self {
        return withValue(part, forKey: "part")
    }

    @warn_unused_result
    func withStarCount(starCount: Int) -> Self {
        return withValue(starCount, forKey: "starCount")
    }

    var careerFactor: Double {
        guard let part = part else { return 0 }
        let starFactor = max(0.1, Double(starCount) / 2)
        let careerMultiplier = career == part.primarySkill ? 1.5 : career == part.secondarySkill ? 1 : 0.5
        return starFactor * careerMultiplier
    }

}

extension Crew: ModelNaming, SegueableType, Segueable {
    class var modelName: String { return "Crew" }
}
