//
//  ResourceConverter.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-10-05.
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

class ResourceConverter: NSManagedObject {

    private dynamic var cachedResourceConverterNode: ResourceConverterNode?
    var resourceConverterNode: ResourceConverterNode? {
        guard let tag = tag else { return nil }
        if cachedResourceConverterNode?.tag != tag {
            cachedResourceConverterNode = part?.partNode?.resourceConverters.values.lazy
                .filter { $0.tag == tag }.first
        }
        return cachedResourceConverterNode
    }

    @warn_unused_result
    func withTag(tag: String) -> Self {
        return withValue(tag, forKey: "tag")
    }

    @warn_unused_result
    func withActiveCount(activeCount: Int) -> Self {
        return withValue(activeCount, forKey: "activeCount")
    }

    @warn_unused_result
    func withPart(part: Part?) -> Self {
        return withValue(part, forKey: "part")
    }

    var name: String? {
        return resourceConverterNode?.converterName
    }

    var inputResources: [String: Double] {
        return resourceConverterNode?.inputResources ?? [:]
    }

    var outputResources: [String: Double] {
        return resourceConverterNode?.outputResources ?? [:]
    }

}

extension ResourceConverter: NamedType { }

extension ResourceConverter: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "ResourceConverter" }

}
