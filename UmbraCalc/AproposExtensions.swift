//
//  AproposExtensions.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-30.
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

private let addVerb = "add"
private let cancelVerb = "cancel"
private let saveVerb = "save"
private let selectVerb = "select"
private let showVerb = "show"

private let listSuffix = "List"

extension SegueableType {

    static var addSegueIdentifier: String { return addVerb + segueTypeNoun }
    static var saveSegueIdentifier: String { return saveVerb + segueTypeNoun }
    static var showSegueIdentifier: String { return showVerb + segueTypeNoun }
    static var showListSegueIdentifier: String { return showSegueIdentifier + listSuffix }

}

extension Segueable {

    var addSegueIdentifier: String { return addVerb + segueNoun }
    var saveSegueIdentifier: String { return saveVerb + segueNoun }
    var showSegueIdentifier: String { return showVerb + segueNoun }
    var showListSegueIdentifier: String { return showSegueIdentifier + listSuffix }

}

extension Segueable where Self: ModelNaming {

    static var segueTypeNoun: String { return modelName }

}
