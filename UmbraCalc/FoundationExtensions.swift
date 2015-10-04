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

    @warn_unused_result
    func withValue(value: AnyObject?, forKey key: String) -> Self {
        setValue(value, forKey: key)
        return self
    }

    @warn_unused_result
    func withValue(value: AnyObject?, forKeyPath keyPath: String) -> Self {
        setValue(value, forKeyPath: keyPath)
        return self
    }

    @warn_unused_result
    func withValuesAndKeys(valuesAndKeys: [String: AnyObject]) -> Self {
        setValuesForKeysWithDictionary(valuesAndKeys)
        return self
    }

}

class ObserverContext: NSObject {
    let keyPath: String
    let options: NSKeyValueObservingOptions
    var context = 0
    init(keyPath: String, options: NSKeyValueObservingOptions = []) {
        self.keyPath = keyPath
        self.options = options
    }
}

extension NSObject {

    func addObserver(observer: NSObject, context: ObserverContext) {
        addObserver(observer, forKeyPath: context.keyPath, options: context.options, context: &context.context)
    }

    func removeObserver(observer: NSObject, context: ObserverContext) {
        removeObserver(observer, forKeyPath: context.keyPath, context: &context.context)
    }
    
}

extension NSIndexPath {

    func offsetSectionBy(sectionOffset: Int) -> NSIndexPath {
        return NSIndexPath(forRow: row, inSection: section + sectionOffset)
    }

    func insetSectionBy(sectionInset: Int) -> NSIndexPath {
        return NSIndexPath(forRow: row, inSection: section - sectionInset)
    }

}
