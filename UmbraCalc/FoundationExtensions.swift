//
//  FoundationExtensions.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-24.
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

extension NSObject {

    func withValue(value: AnyObject?, forKey key: String) -> Self {
        setValue(value, forKey: key)
        return self
    }

    func withValue(value: AnyObject?, forKeyPath keyPath: String) -> Self {
        setValue(value, forKeyPath: keyPath)
        return self
    }

    func withValuesAndKeys(valuesAndKeys: [String: AnyObject]) -> Self {
        setValuesForKeysWithDictionary(valuesAndKeys)
        return self
    }

}
