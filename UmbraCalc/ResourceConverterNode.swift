//
//  ResourceConverterNode.swift
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

private let converterNameKey = "ConverterName"
private let inputResourceKey = "INPUT_RESOURCE"
private let outputResourceKey = "OUTPUT_RESOURCE"
private let ratioKey = "Ratio"
private let resourceNameKey = "ResourceName"
private let tagKey = "tag"

class ResourceConverterNode: NSObject {

    let tag: String
    let converterName: String
    let inputResources: [String: Double]
    let outputResources: [String: Double]

    private static func resourceWithNode(node: [NSObject: AnyObject]) -> (String, Double) {
        return (node[resourceNameKey] as? String ?? "", Double(node[ratioKey] as? String ?? "0") ?? 0)
    }

    private static func resourcesWithNode(node: AnyObject?) -> [String: Double] {
        if let node = node as? [NSObject: AnyObject] {
            let resource = resourceWithNode(node)
            return [resource.0: resource.1]
        } else if let nodes = node as? [[NSObject: AnyObject]] {
            return nodes.map(resourceWithNode).reduce([:]) {
                var ret = $0
                ret[$1.0] = $1.1
                return ret
            }
        } else {
            return [:]
        }
    }

    init(configNode: [NSObject: AnyObject]) {
        tag = configNode[tagKey] as? String ?? ""
        converterName = configNode[converterNameKey] as? String ?? ""
        inputResources = ResourceConverterNode.resourcesWithNode(configNode[inputResourceKey])
        outputResources = ResourceConverterNode.resourcesWithNode(configNode[outputResourceKey])
    }

}

extension ResourceConverterNode: ResourceConverting {

    var activeResourceConvertingCount: Int { return 1 }

}
