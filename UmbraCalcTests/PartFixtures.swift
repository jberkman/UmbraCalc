//
//  PartFixtures.swift
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

@testable import UmbraCalc

class PartFixtures: NSObject {

    class func configNodeWithName(name: String, title: String, crewCapacity: Int, livingSpaces: Int, workspaces: Int, efficiencyParts: [String: Int] = [:]) -> [NSObject: AnyObject] {
        var module = [
            "name": "MKSModule",
            "livingSpace": String(livingSpaces),
            "workSpace": String(workspaces)
        ]
        if !efficiencyParts.isEmpty {
            module["efficiencyPart"] = efficiencyParts.keys.map { "\($0),\(efficiencyParts[$0]!)" }.joinWithSeparator(",")
        }
        return [
            "PART": [
                "name": name,
                "title": title,
                "CrewCapacity": String(crewCapacity),
                "MODULE": module
            ]
        ]
    }

    class func partNodeWithName(name: String, title: String, crewCapacity: Int, livingSpaces: Int, workspaces: Int, efficiencyParts: [String: Int] = [:]) -> PartNode? {
        return PartNode(configNode: configNodeWithName(name, title: title, crewCapacity: crewCapacity, livingSpaces: livingSpaces, workspaces: workspaces, efficiencyParts: efficiencyParts))
    }

}

extension ManagingObjectContext {

    func insertPartWithName(name: String, crewCapacity: Int, livingSpaces: Int, workspaces: Int, efficiencyParts: [String: Int] = [:]) -> Part {
        let partNode = PartFixtures.partNodeWithName(name, title: name, crewCapacity: crewCapacity, livingSpaces: livingSpaces, workspaces: workspaces, efficiencyParts: efficiencyParts)
        return insertPartWithPartName(name)!.withValue(partNode, forKey: "cachedPartNode")
    }

    func insertAeroponicsPart() -> Part {
        return insertPartWithName("Aeroponics", crewCapacity: 2, livingSpaces: 0, workspaces: 1)
    }

    func insertHabRingPart() -> Part {
        return insertPartWithName("Hab Ring", crewCapacity: 10, livingSpaces: 10, workspaces: 0)
    }

    func insertKerbitatPart() -> Part {
        return insertPartWithName("Kerbitat", crewCapacity: 2, livingSpaces: 0, workspaces: 1, efficiencyParts: [
            "Habitation Module": 2
            ])
    }

    func insertSurfaceWorkspacePart() -> Part {
        return insertPartWithName("MKS Workspace", crewCapacity: 1, livingSpaces: 0, workspaces: 2)
    }

    func insertOrbitalWorkspacePart() -> Part {
        return insertPartWithName("OKS Workspace", crewCapacity: 0, livingSpaces: 0, workspaces: 4)
    }

    func insertPDUPart() -> Part {
        return insertPartWithName("PDU", crewCapacity: 2, livingSpaces: 0, workspaces: 0)
    }

    func insertPioneerPart() -> Part {
        return insertPartWithName("Pioneer", crewCapacity: 2, livingSpaces: 0, workspaces: 1)
    }

    func insertMobileRefineryPart() -> Part {
        return insertPartWithName("Mobile Refinery", crewCapacity: 4, livingSpaces: 0, workspaces: 5)
    }

    func insertTrainingAkademyPart() -> Part {
        return insertPartWithName("Training Akademy", crewCapacity: 12, livingSpaces: 0, workspaces: 5)
    }

    func insertAuxiliaryControlModulePart() -> Part {
        return insertPartWithName("Auxiliary Control Module", crewCapacity: 1, livingSpaces: 0, workspaces: 0)
    }

    func insertAirlockPart() -> Part {
        return insertPartWithName("Airlock", crewCapacity: 1, livingSpaces: 0, workspaces: 0)
    }

    func insertColonyHubPart() -> Part {
        return insertPartWithName("Colony Hub", crewCapacity: 0, livingSpaces: 0, workspaces: 1)
    }

    func insertCommLabPart() -> Part {
        return insertPartWithName("Comm Lab", crewCapacity: 1, livingSpaces: 0, workspaces: 0)
    }

    func insertCommandPodPart() -> Part {
        return insertPartWithName("Command Pod", crewCapacity: 2, livingSpaces: 0, workspaces: 1)
    }

    func insertHabitationModulePart() -> Part {
        return insertPartWithName("Habitation Module", crewCapacity: 4, livingSpaces: 4, workspaces: 0)
    }

    func insertWorkshopModule() -> Part {
        return insertPartWithName("Workshop", crewCapacity: 4, livingSpaces: 0, workspaces: 4)
    }

}
