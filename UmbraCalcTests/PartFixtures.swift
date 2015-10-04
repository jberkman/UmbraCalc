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

extension CoreDataStackTestCase {

    func part(name: String, crewCapacity: Int, livingSpaces: Int, workspaces: Int, efficiencyParts: [String: Int] = [:]) -> Part {
        let partNode = PartFixtures.partNodeWithName(name, title: name, crewCapacity: crewCapacity, livingSpaces: livingSpaces, workspaces: workspaces, efficiencyParts: efficiencyParts)
        return try! Part(insertIntoManagedObjectContext: managedObjectContext!).withPartName(name).withValue(partNode, forKey: "cachedPartNode")
    }

    func aeroponics() -> Part {
        return part("Aeroponics", crewCapacity: 2, livingSpaces: 0, workspaces: 1)
    }

    func habRing() -> Part {
        return part("Hab Ring", crewCapacity: 10, livingSpaces: 10, workspaces: 0)
    }

    func kerbitat() -> Part {
        return part("Kerbitat", crewCapacity: 2, livingSpaces: 0, workspaces: 1, efficiencyParts: [
            "Habitation Module": 2
            ])
    }

    func surfaceWorkspace() -> Part {
        return part("MKS Workspace", crewCapacity: 1, livingSpaces: 0, workspaces: 2)
    }

    func orbitalWorkspace() -> Part {
        return part("OKS Workspace", crewCapacity: 0, livingSpaces: 0, workspaces: 4)
    }

    func PDU() -> Part {
        return part("PDU", crewCapacity: 2, livingSpaces: 0, workspaces: 0)
    }

    func pioneer() -> Part {
        return part("Pioneer", crewCapacity: 2, livingSpaces: 0, workspaces: 1)
    }

    func mobileRefinery() -> Part {
        return part("Mobile Refinery", crewCapacity: 4, livingSpaces: 0, workspaces: 5)
    }

    func trainingAkademy() -> Part {
        return part("Training Akademy", crewCapacity: 12, livingSpaces: 0, workspaces: 5)
    }

    func auxiliaryControlModule() -> Part {
        return part("Auxiliary Control Module", crewCapacity: 1, livingSpaces: 0, workspaces: 0)
    }

    func airlock() -> Part {
        return part("Airlock", crewCapacity: 1, livingSpaces: 0, workspaces: 0)
    }

    func colonyHub() -> Part {
        return part("Colony Hub", crewCapacity: 0, livingSpaces: 0, workspaces: 1)
    }

    func commLab() -> Part {
        return part("Comm Lab", crewCapacity: 1, livingSpaces: 0, workspaces: 0)
    }

    func commandPod() -> Part {
        return part("Command Pod", crewCapacity: 2, livingSpaces: 0, workspaces: 1)
    }

    func habitationModule() -> Part {
        return part("Habitation Module", crewCapacity: 4, livingSpaces: 4, workspaces: 0)
    }

    func workshopModule() -> Part {
        return part("Workshop", crewCapacity: 4, livingSpaces: 0, workspaces: 4)
    }

}
