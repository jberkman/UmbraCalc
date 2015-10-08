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

protocol Addable {
    @warn_unused_result
    func +(lhs: Self, rhs: Self) -> Self

    static var additiveIdentity: Self { get }
}

protocol Subtractable {
    @warn_unused_result
    func -(lhs: Self, rhs: Self) -> Self
}

protocol Multipliable {
    @warn_unused_result
    func *(lhs: Self, rhs: Self) -> Self

    static var multiplicativeIdentity: Self { get }
}

protocol Dividable {
    @warn_unused_result
    func /(lhs: Self, rhs: Self) -> Self
}

protocol ArithmeticType: Addable, Subtractable, Multipliable, Dividable { }

extension Int: ArithmeticType {
    static var additiveIdentity = 0
    static var multiplicativeIdentity = 1
}

extension Double: ArithmeticType {
    static var additiveIdentity = 0.0
    static var multiplicativeIdentity = 1.0
}

func +<Key: Hashable, Value: Addable>(lhs: Dictionary<Key, Value>, rhs: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
    return (Array(lhs.keys) + Array(rhs.keys)).reduce([Key: Value]()) {
        var ret = $0
        ret[$1] = (lhs[$1] ?? Value.additiveIdentity) + (rhs[$1] ?? Value.additiveIdentity)
        return ret
    }
}

func *<Key: Hashable, Value: Multipliable>(lhs: Dictionary<Key, Value>, rhs: Value) -> Dictionary<Key, Value> {
    return lhs.keys.reduce([:]) {
        var ret = $0
        ret[$1] = (lhs[$1] ?? Value.multiplicativeIdentity) * rhs
        return ret
    }
}
