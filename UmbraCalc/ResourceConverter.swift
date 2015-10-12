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

import Apropos
import Balsa
import Foundation
import CoreData

class ResourceConverter: ScopedEntity {

    private dynamic var cachedResourceConverterNode: ResourceConverterNode?

    @NSManaged var activeCount: Int16

    @NSManaged private var primitivePart: Part?
    @NSManaged private var primitiveTag: String?

    override var scopeKey: String {
        return [entity.name!, tag ?? "", creationDateScopeKey].joinWithSeparator("-")
    }

    dynamic var part: Part? {
        get {
            willAccessValueForKey("part")
            let ret = primitivePart
            didAccessValueForKey("part")
            return ret
        }
        set {
            willChangeValueForKey("part")
            primitivePart = newValue
            rootScope = newValue?.rootScope
            scopeGroup = newValue?.scopeGroup
            didChangeValueForKey("part")
        }
    }

    override var superscope: ScopedEntity? {
        return part
    }

    dynamic var tag: String? {
        get {
            willAccessValueForKey("tag")
            let ret = primitiveTag
            didAccessValueForKey("tag")
            return ret
        }
        set {
            willChangeValueForKey("tag")
            primitiveTag = newValue
            setScopeNeedsUpdate()
            didChangeValueForKey("tag")
        }
    }

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

}

extension ResourceConverter: ResourceConverting {

    var inputResources: [String: Double] {
        guard let resources = resourceConverterNode?.inputResources else { return [:] }
        return resources * (Double(activeCount) * (part?.efficiency ?? 0))
    }

    var outputResources: [String: Double] {
        guard let resources = resourceConverterNode?.outputResources else { return [:] }
        return resources * (Double(activeCount) * (part?.efficiency ?? 0))
    }

    var activeResourceConvertingCount: Int { return Int(activeCount) }

}

extension ResourceConverter: NamedType {

    var name: String? {
        return resourceConverterNode?.converterName
    }

}

extension ResourceConverter: ModelNaming, SegueableType, Segueable {

    class var modelName: String { return "ResourceConverter" }

}
