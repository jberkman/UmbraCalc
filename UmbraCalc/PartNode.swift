//
//  PartNode.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-25.
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
import ObjectiveC

private var partNodeAssociatedObjectKey = 0
private let partsExtension = "cfg"
private let partsSubdirectory = "Parts"

private let crewBonusKey = "CrewBonus"
private let crewCapacityKey = "CrewCapacity"
private let descriptionKey = "description"
private let efficiencyPartListKey = "efficiencyPart"
private let hasGeneratorsKey = "hasGenerators"
private let livingSpaceKey = "livingSpace"
private let maxEfficencyKey = "MaxEfficiency"
private let moduleKey = "MODULE"
private let moduleResourceConverterKey = "ModuleResourceConverter"
private let nameKey = "name"
private let partKey = "PART"
private let primarySkillKey = "PrimarySkill"
private let secondarySkillKey = "SecondarySkill"
private let titleKey = "title"
private let workSpaceKey = "workSpace"

private let MKSModuleValue = "MKSModule"

private let efficiencyPartDelimiter = ","

private let defaultCrewBonus = 0.1
private let defaultHasGenerators = true
private let defaultMaxEfficiency = 2.5
private let defaultPrimarySkill = Crew.engineerTitle
private let defaultSecondarySkill = Crew.scientistTitle

extension NSBundle {

    var partNodes: [PartNode] {
        if let cachedNodes = objc_getAssociatedObject(self, &partNodeAssociatedObjectKey) as? [PartNode] {
            return cachedNodes
        }
        guard let URLs = URLsForResourcesWithExtension(partsExtension, subdirectory: partsSubdirectory) else { return [] }
        let nodes = URLs.map { PartNode(URL: $0) }.filter { $0 != nil }.map { $0! }
        objc_setAssociatedObject(self, &partNodeAssociatedObjectKey, nodes, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return nodes
    }

}

class PartNode: NSObject {

    let name: String
    let title: String
    let descriptionText: String
    let crewCapacity: Int
    let crewBonus: Double
    let hasGenerators: Bool
    let maxEfficiency: Double
    let workspaceCount: Int
    let livingSpaceCount: Int
    let primarySkill: String
    let secondarySkill: String
    let resourceConverters: [String: ResourceConverterNode]
    let efficiencyParts: [String: Int]

    var crewed: Bool { return crewCapacity > 0 }

    init?(configNode: [NSObject: AnyObject]) {
        guard let part = configNode[partKey] as? [NSObject: AnyObject] else {
            name = ""
            title = ""
            descriptionText = ""
            crewCapacity = 0
            self.crewBonus = 0
            self.hasGenerators = false
            self.maxEfficiency = 0
            self.workspaceCount = 0
            self.livingSpaceCount = 0
            self.primarySkill = ""
            self.secondarySkill = ""
            self.resourceConverters = [:]
            self.efficiencyParts = [:]
            super.init()
            return nil
        }

        func boolWithValue(value: AnyObject?, defaultValue: Bool = false) -> Bool {
            return (value as? String)?.lowercaseString.hasPrefix("t") ?? defaultValue
        }

        func intWithValue(value: AnyObject?, defaultValue: Int = 0) -> Int {
            guard let s = value as? String else { return defaultValue }
            return Int(s) ?? defaultValue
        }

        func doubleWithValue(value: AnyObject?, defaultValue: Double = 0) -> Double {
            guard let s = value as? String else { return defaultValue }
            return Double(s) ?? defaultValue
        }

        name = part[nameKey] as? String ?? ""
        title = part[titleKey] as? String ?? ""
        descriptionText = part[descriptionKey] as? String ?? (part[descriptionKey] as? [String])?.joinWithSeparator("\n") ?? ""
        crewCapacity = intWithValue(part[crewCapacityKey])

        let modules: [[NSObject: AnyObject]]
        if let nodeModules = part[moduleKey] as? [[NSObject: AnyObject]] {
            modules = nodeModules
        } else if let module = part[moduleKey] as? [NSObject: AnyObject] {
            modules = [module]
        } else {
            modules = []
        }

        var workspaceCount = 0
        var livingSpaceCount = 0
        var crewBonus = defaultCrewBonus
        var hasGenerators = defaultHasGenerators
        var maxEfficiency = defaultMaxEfficiency
        var primarySkill = defaultPrimarySkill
        var secondarySkill = defaultSecondarySkill
        var efficiencyPartList: String?
        var resourceConverters = [String: ResourceConverterNode]()

        for module in modules {
            guard module[nameKey] as? String != moduleResourceConverterKey else {
                let resourceConverter = ResourceConverterNode(configNode: module)
                resourceConverters[resourceConverter.tag] = resourceConverter
                continue
            }
            guard module[nameKey] as? String == MKSModuleValue else { continue }
            workspaceCount = intWithValue(module[workSpaceKey])
            livingSpaceCount = intWithValue(module[livingSpaceKey])
            crewBonus = doubleWithValue(module[crewBonusKey], defaultValue: defaultCrewBonus)
            hasGenerators = boolWithValue(module[hasGeneratorsKey], defaultValue: defaultHasGenerators)
            maxEfficiency = doubleWithValue(module[maxEfficencyKey], defaultValue: defaultMaxEfficiency)
            primarySkill = module[primarySkillKey] as? String ?? defaultPrimarySkill
            secondarySkill = module[secondarySkillKey] as? String ?? defaultSecondarySkill
            efficiencyPartList = module[efficiencyPartListKey] as? String
        }

        self.workspaceCount = workspaceCount
        self.livingSpaceCount = livingSpaceCount
        self.crewBonus = crewBonus
        self.hasGenerators = hasGenerators
        self.maxEfficiency = maxEfficiency
        self.primarySkill = primarySkill
        self.secondarySkill = secondarySkill
        self.resourceConverters = resourceConverters

        if let partList = efficiencyPartList {
            let elements = partList.characters.split { String($0) == efficiencyPartDelimiter }.map { String($0) }
            efficiencyParts = 0.stride(to: elements.count, by: 2)
                .map { (elements[$0], Int(elements[$0 + 1]) ?? 0) }
                .reduce([:]) {
                    var ret = $0
                    ret[$1.0] = $1.1
                    return ret
            }
        } else {
            efficiencyParts = [:]
        }

        super.init()
    }

    convenience init?(URL: NSURL) {
        guard let data = NSData(contentsOfURL: URL) else {
            print("failed to load URL:", URL)
            self.init(configNode: [:])
            return nil
        }

        self.init(configNode: ConfigNode.configNodeWithData(data))
    }

    convenience init?(named name: String, inBundle bundle: NSBundle = NSBundle.mainBundle()) {
        guard let URL = bundle.URLForResource(name, withExtension: partsExtension, subdirectory: partsSubdirectory) else {
            print("failed to find file named:", name)
            self.init(configNode: [:])
            return nil
        }

        self.init(URL: URL)
    }

}
