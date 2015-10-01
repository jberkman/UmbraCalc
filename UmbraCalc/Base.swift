//
//  Base.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
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

class Base: Vessel {

    func withKolony(kolony: Kolony?) -> Self {
        return withValue(kolony, forKey: "kolony")
    }

}

extension Base {

    override class var modelName: String { return "Base" }

}
