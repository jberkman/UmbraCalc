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

    var title: String? { return partNode?.title }

    var displayName: String { return partNode?.title ?? "Untitled Part" }

    var displaySummary: String {
        var labels = [String]()
        if crewed {
            labels.append("\(crewCount) of \(crewCapacity) Crew")
        } else {
            labels.append("\(count) Installed")
        }
        if partNode?.hasGenerators == true {
            labels.append("\(percentFormatter.stringFromNumber(efficiency)!) Efficiency")
        }
        return labels.joinWithSeparator(", ")
    }

}

extension Part: NamedType {

    var name: String? { return partNode?.name }
    
}

extension Part: Countable { }

extension Part: ResourceConvertingCollectionType {

    var resourceConvertingCollection: AnyForwardCollection<ResourceConverting> {
        return AnyForwardCollection((resourceConverters as? Set<ResourceConverter>)?.map { $0 as ResourceConverting } ?? [])
    }

}

extension Part: CrewingCollectionType {

    var crewingCollection: AnyForwardCollection<Crewing> {
        return AnyForwardCollection((crew as? Set<Crew>)?.map { $0 as Crewing } ?? [])
    }

}

extension Part: Kolonizing {

    var crewCapacity: Int { return Int(count) * (partNode?.crewCapacity ?? 0) }
    var workspaceCount: Int { return Int(count) * (partNode?.workspaceCount ?? 0) }
    var livingSpaceCount: Int { return Int(count) * (partNode?.livingSpaceCount ?? 0) }

}

extension Part: Crewable {

    var primarySkill: String? { return partNode?.primarySkill }
    var secondarySkill: String? { return partNode?.secondarySkill }

    var crewBonus: Double { return partNode?.crewBonus ?? 0 }
    var efficiencyFactors: [String: Double] { return partNode?.efficiencyParts ?? [:] }
    var maxEfficiency: Double { return partNode?.maxEfficiency ?? 0 }

    var crewableCollection: CrewableCollectionType? { return vessel }

}

extension Part: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "Part" }

}
