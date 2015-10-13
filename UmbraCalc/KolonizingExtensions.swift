//
//  KolonizingExtensions.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-07.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

private let minEfficiency = 0.25
let secondsPerDay = Double(60 * 60 * 6)
let secondsPerYear = secondsPerDay * 426

private let initialSupplies = [
    "Fertilizer": Double.infinity,
    "Machinery": Double.infinity,
    "Plutonium-238": Double.infinity
]

extension ResourceConverting {

    func outputResourcesWithInputConstraints(inputConstraints: [String: Double]) -> [String: Double] {
        let constraint = Set(inputResources.keys).intersect(Set(inputConstraints.keys)).map({ inputConstraints[$0]! }).minElement() ?? 1
        return outputResources * constraint
    }

}

extension ResourceConvertingCollectionType {

    var inputResources: [String: Double] {
        return resourceConvertingCollection.map { $0.inputResources }.reduce([:], combine: +)
    }

    var outputResources: [String: Double] {
        return resourceConvertingCollection.map { $0.outputResources }.reduce([:], combine: +)
    }

    var activeResourceConvertingCount: Int {
        return resourceConvertingCollection.map { $0.activeResourceConvertingCount }.reduce(0, combine: +)
    }

    func inputConstraintsWithOutputResources(outputResources: [String: Double]) -> [String: Double] {
        return inputResources.reduce([:]) {
            guard let output = outputResources[$1.0] else {
                var ret = $0
                ret[$1.0] = 0
                return ret
            }
            guard output < $1.1 else { return $0 }
            var ret = $0
            ret[$1.0] = output / $1.1
            return ret
        }
    }

    func initialSupplyInputConstraintsWithOutputResources(outputResources: [String: Double]) -> [String: Double] {
        return initialSupplies.reduce(inputConstraintsWithOutputResources(outputResources + initialSupplies)) {
            guard $0[$1.0] == nil else { return $0 }
            var ret = $0
            ret[$1.0] = 1
            return ret
        }
    }

}

extension Crewing {

    static var engineerTitle: String { return "Engineer" }
    static var scientistTitle: String { return "Scientist" }
    static var pilotTitle: String { return "Pilot" }

    var starString: String {
        return String(count: Int(starCount), repeatedValue: "⭐️")
    }

    var crewDisplayName: String {
        let name = self.name?.isEmpty == false ? self.name! : "Unnamed Crew"
        return "\(name) \(starString)"
    }

    var careerFactor: Double {
        guard let crewable = crewable else { return 0 }
        let starFactor = max(0.1, Double(starCount) / 2)
        let careerMultiplier = career == crewable.primarySkill ? 1.5 : career == crewable.secondarySkill ? 1 : 0.5
        return starFactor * careerMultiplier
    }

}


extension CrewingCollectionType {

    var crewCount: Int { return Int(crewingCollection.count) }

    var careerFactor: Double {
        return crewingCollection.map { $0.careerFactor }.reduce(0, combine: +)
    }

}

extension KolonizingCollectionType {

    var crewCapacity: Int {
        return kolonizingCollection.map { $0.crewCapacity }.reduce(0, combine: +)
    }

    var livingSpaceCount: Int {
        return kolonizingCollection.map { $0.livingSpaceCount }.reduce(0, combine: +)
    }

    var workspaceCount: Int {
        return kolonizingCollection.map { $0.workspaceCount }.reduce(0, combine: +)
    }

    var constrainedOutputs: [String: Double] {
        let crewOutputs = crewingCollection.map { $0.outputResources }.reduce([:], combine: +)
        return (0 ..< 5).reduce(crewOutputs) { inputs, _ in
            let inputConstraints = initialSupplyInputConstraintsWithOutputResources(inputs)
            let constrainedOutputs = resourceConvertingCollection.map { $0.outputResourcesWithInputConstraints(inputConstraints) }.reduce([:], combine: +)
            return constrainedOutputs + crewOutputs
        }
    }

    var netResourceConversion: [String: Double] {
        let outputs = constrainedOutputs
        let inputConstraints = initialSupplyInputConstraintsWithOutputResources(outputs)
        let crewInputs = crewingCollection.map { $0.inputResources }.reduce([:], combine: +)
        return outputs - inputConstraints * inputResources - crewInputs
    }

}

extension Crewable {

    var kolonizingEfficiency: Double {
        guard !efficiencyFactors.isEmpty, let collection = crewableCollection?.containingKolonizingCollection?.kolonizingCollection else { return 0 }
        return collection
            .filter { $0.name != nil && efficiencyFactors[$0.name!] != nil }
            .map { Double(($0 as? Countable)?.count ?? 0) * efficiencyFactors[$0.name!]! }
            .reduce(0, combine: +)
    }

    var crewingEfficiency: Double {
        guard let vessel = crewableCollection, kolony = vessel.containingKolonizingCollection where vessel.crewCount > 0 else { return 0 }
        let maxWorkspaceRatio = 3.0
        let workspaces = Double(kolony.workspaceCount) + Double(vessel.crewCapacity) / 4
        let workspaceRatio = min(maxWorkspaceRatio, workspaces / Double(vessel.crewCount))
        let workUnits = workspaceRatio * vessel.happiness * (careerFactor + vessel.careerFactor * crewBonus)
        return min(maxEfficiency, max(minEfficiency, workUnits / Double(kolony.activeResourceConvertingCount)))
    }

    var efficiency: Double {
        return efficiencyFactors.isEmpty ? crewingEfficiency : max(minEfficiency, crewingEfficiency + kolonizingEfficiency)
    }

    var crewed: Bool {
        return crewCapacity > 0
    }

}

extension CrewableCollectionType {

    var happiness: Double {
        guard let kolony = containingKolonizingCollection where kolony.crewCount > 0 else { return 0 }

        let minHappinessFactor = 0.5
        let maxHappinessFactor = 1.5

        let sadness = min(5, Double(kolony.crewCount)) / 5
        let livingSpaces = Double(kolony.livingSpaceCount) + Double(kolony.crewCapacity) / 10
        return sadness * max(minHappinessFactor, min(maxHappinessFactor, livingSpaces / Double(crewCount)))
    }

}
