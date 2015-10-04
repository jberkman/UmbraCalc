//
//  NamedType.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-27.
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

protocol NamedType {

    var name: String? { get }

}

extension NamedType {

    static var nameSortDescriptor: NSSortDescriptor {
        return NSSortDescriptor(key: "name", ascending: true)
    }

}

protocol MutableNamedType: NamedType {

    var name: String? { get set }

}

extension ModelNaming where Self: NamedType {

    var displayName: String {
        guard name?.isEmpty == false else { return "Unnamed \(modelName)" }
        return name!
    }
    
}
