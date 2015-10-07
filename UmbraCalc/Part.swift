//
//  Part.swift
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

import Foundation
import CoreData

private let minEfficiency = 0.25

private let percentFormatter = NSNumberFormatter().withValue(NSNumberFormatterStyle.PercentStyle.rawValue, forKey: "numberStyle")

class Part: NSManagedObject {

    private dynamic var cachedPartNode: PartNode? {
        didSet {
            guard var resourceConverterNodes = cachedPartNode?.resourceConverters else { return }
            (resourceConverters as? Set<ResourceConverter>)?.filter {
                guard let tag = $0.tag where resourceConverterNodes[tag] != nil else { return true }
                resourceConverterNodes[tag] = nil
                return false
                }.forEach { $0.deleteEntity() }
            guard let managedObjectContext = managedObjectContext else { return }
            resourceConverterNodes.values.forEach {
                _ = try? ResourceConverter(insertIntoManagedObjectContext: managedObjectContext).withTag($0.tag).withPart(self)
            }
        }
    }

    var partNode: PartNode? {
        guard let name = partName else { return nil }
        if cachedPartNode?.name != name {
            cachedPartNode = PartNode(named: name)
        }
        return cachedPartNode
    }

    @warn_unused_result
    func withCount(count: Int) -> Self {
        return withValue(count, forKey: "count")
    }

    @warn_unused_result
    func withAdditionalCount(additionalCount: Int) -> Self {
        return withCount(Int(count) + additionalCount)
    }

    @warn_unused_result
    func withVessel(vessel: Vessel?) -> Self {
        return withValue(vessel, forKey: "vessel")
    }

    @warn_unused_result
    func withCrew<S: SequenceType where S.Generator.Element == Crew>(crew: S) -> Self {
        return withValue(Set(crew), forKey: "crew")
    }

    @warn_unused_result
    func withPartName(partName: String?) -> Self {
        let ret = withValue(partName, forKey: "partName")
        // FIXME: how to override setting in swift?
        _ = partNode
        return ret
    }

    var name: String? { return partNode?.name }
    var title: String? { return partNode?.title }
    var crewCapacity: Int { return Int(count) * (partNode?.crewCapacity ?? 0) }
    var crewBonus: Double { return partNode?.crewBonus ?? 0 }
    var hasGenerators: Bool { return partNode?.hasGenerators == true }
    var maxEfficiency: Double { return partNode?.maxEfficiency ?? 0 }
    var workspaceCount: Int { return Int(count) * (partNode?.workspaceCount ?? 0) }
    var livingSpaceCount: Int { return Int(count) * (partNode?.livingSpaceCount ?? 0) }
    var primarySkill: String? { return partNode?.primarySkill }
    var secondarySkill: String? { return partNode?.secondarySkill }
    var efficiencyParts: [String: Int] { return partNode?.efficiencyParts ?? [:] }

    var crewed: Bool { return partNode?.crewed == true }

    var displayName: String { return partNode?.title ?? "Untitled Part" }
    var displaySummary: String {
        var labels = [String]()
        if crewed {
            labels.append("\(crew?.count ?? 0) of \(crewCapacity) Crew")
        } else {
            labels.append("\(count) Installed")
        }
        if hasGenerators {
            labels.append("\(percentFormatter.stringFromNumber(efficiency)!) Efficiency")
        }
        return labels.joinWithSeparator(", ")
    }

    private func crewSum(transform: (Crew) -> Int) -> Int {
        return (crew as? Set<Crew>)?.map(transform).reduce(0, combine: +) ?? 0
    }

    private func crewSum(transform: (Crew) -> Double) -> Double {
        return (crew as? Set<Crew>)?.map(transform).reduce(0.0, combine: +) ?? 0
    }

    var crewCareerFactor: Double {
        return crewSum { $0.careerFactor }
    }

    var activeResourceConverterCount: Int {
        return (resourceConverters as? Set<ResourceConverter>)?.map { Int($0.activeCount) }.reduce(0, combine: +) ?? 0
    }

    var partsEfficiency: Double {
        guard !efficiencyParts.isEmpty, let vessel = vessel else { return 0 }
        return Double(vessel.efficiencyParts
            .filter { $0.name != nil && efficiencyParts[$0.name!] != nil }
            .map { Int($0.count) * efficiencyParts[$0.name!]! }
            .reduce(0, combine: +))
    }

    var crewEfficiency: Double {
        guard let vessel = vessel where vessel.crewCount > 0 else { return 0 }
        let maxWorkspaceRatio = 3.0
        let workspaces = Double(vessel.efficiencyWorkspaceCount) + Double(vessel.crewCapacity) / 4
        let workspaceRatio = min(maxWorkspaceRatio, workspaces / Double(vessel.crewCount))
        let workUnits = workspaceRatio * vessel.crewHappiness * (crewCareerFactor + vessel.crewCareerFactor * crewBonus)
        return min(maxEfficiency, max(minEfficiency, workUnits / Double(vessel.efficiencyActiveResourceConverterCount)))
    }

    var efficiency: Double {
        return efficiencyParts.isEmpty ? crewEfficiency : max(minEfficiency, crewEfficiency + partsEfficiency)
    }

}

extension Part: NamedType { }

extension Part: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "Part" }

}
