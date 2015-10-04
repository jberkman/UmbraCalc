//
//  Base.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
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
import CoreData

private let defaultParts = [ "MKV_AgModule", "MKV_HabModule", "MKV_Lander", "MKV_Pod", "MKV_PowerPack", "MKV_Workshop" ]

class Base: Vessel {

    @warn_unused_result
    func withKolony(kolony: Kolony?) -> Self {
        return withValue(kolony, forKey: "kolony")
    }

    @warn_unused_result
    func withDefaultParts() throws -> Self {
        guard let managedObjectContext = managedObjectContext else { return self }
        return try withParts(defaultParts.map { try Part(insertIntoManagedObjectContext: managedObjectContext).withPartName($0) })
    }

    override var happinessCrewCapacity: Int {
        return kolony?.crewCapacity ?? crewCapacity
    }

    override var happinessCrewCount: Int {
        return kolony?.crewCount ?? crewCount
    }

    override var happinessLivingSpaceCount: Int {
        return kolony?.livingSpaceCount ?? livingSpaceCount
    }

    override var efficiencyActiveResourceConverterCount: Int {
        return kolony?.activeResourceConverterCount ?? activeResourceConverterCount
    }

    override var efficiencyWorkspaceCount: Int {
        return kolony?.workspaceCount ?? workspaceCount
    }

    override var efficiencyParts: Set<Part> {
        return kolony?.parts ?? parts as? Set<Part> ?? Set()
    }

}

extension Base {

    override class var modelName: String { return "Base" }

}
