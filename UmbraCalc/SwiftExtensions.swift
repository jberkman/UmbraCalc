//
//  SwiftExtensions.swift
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

func *<Key: Hashable>(lhs: Dictionary<Key, Double>, rhs: Double) -> Dictionary<Key, Double> {
    return lhs.keys.reduce([:]) {
        var ret = $0
        ret[$1] = (lhs[$1] ?? 1) * rhs
        return ret
    }
}

func +<Key: Hashable>(lhs: Dictionary<Key, Double>, rhs: Dictionary<Key, Double>) -> Dictionary<Key, Double> {
    return (Array(lhs.keys) + Array(rhs.keys)).reduce([Key: Double]()) {
        var ret = $0
        ret[$1] = (lhs[$1] ?? 0) + (rhs[$1] ?? 0)
        return ret
    }
}
