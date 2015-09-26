//
//  ConfigNode.swift
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

private let assignmentToken = "="
private let closeNodeToken = "}"
private let commentToken = "//"
private let openNodeToken = "{"

private let keyDelimiterCharacterSet: NSCharacterSet = {
    let set = NSCharacterSet.whitespaceAndNewlineCharacterSet().mutableCopy() as! NSMutableCharacterSet
    set.addCharactersInString(assignmentToken)
    set.addCharactersInString(closeNodeToken)
    set.addCharactersInString(openNodeToken)
    return set
    }()

private let assignmentDelimiterCharacterSet: NSCharacterSet = {
    let set = NSCharacterSet.newlineCharacterSet().mutableCopy() as! NSMutableCharacterSet
    set.addCharactersInString(closeNodeToken)
    return set
}()


class ConfigNode: NSObject {

    class func configNodeWithData(data: NSData) -> [NSObject: AnyObject] {
        guard let s = String(data: data, encoding: NSUTF8StringEncoding) else { return [:] }
        let scanner = NSScanner(string: s)

        func scanCommentsFromString(string: String, intoString result: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
            guard NSScanner(string: string).scanUpToString(commentToken, intoString: result) else {
                result.memory = ""
                return true
            }
            return true
        }

        func scanComments() {
            var originalLocation = scanner.scanLocation
            while scanner.scanString(commentToken, intoString: nil) {
                guard scanner.scanUpToCharactersFromSet(NSCharacterSet.newlineCharacterSet(), intoString: nil) else {
                    scanner.scanLocation = originalLocation
                    return
                }
                originalLocation = scanner.scanLocation
            }
        }

        func scanKey(result: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
            guard scanner.scanUpToCharactersFromSet(keyDelimiterCharacterSet, intoString: result) else { return false }
            guard let tmpResult = result.memory else { return true }
            return scanCommentsFromString(tmpResult as String, intoString: result)
        }

        func scanAssignment(result: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
            guard scanner.scanString(assignmentToken, intoString: nil) else { return false }
            guard scanner.scanUpToCharactersFromSet(assignmentDelimiterCharacterSet, intoString: result) else { return false }
            guard let tmpResult = result.memory else { return true }
            return scanCommentsFromString(tmpResult as String, intoString: result)
        }

        func scanNode(result: AutoreleasingUnsafeMutablePointer<NSDictionary?>) -> Bool {
            var ret = [NSObject: AnyObject]()
            func accumulateValue(value: AnyObject, forKey key: String) {
                guard let oldValue = ret[key] else {
                    ret[key] = value
                    return
                }
                if let oldValues = oldValue as? [AnyObject] {
                    ret[key] = oldValues + [value]
                } else {
                    ret[key] = [oldValue, value]
                }
            }

            let originalLocation = scanner.scanLocation
            guard scanner.scanString(openNodeToken, intoString: nil) else { return false }
            scanComments()
            while !scanner.scanString(closeNodeToken, intoString: nil) {
                scanComments()
                var key: NSString?
                guard scanKey(&key) else {
                    scanner.scanLocation = originalLocation
                    return false
                }

                scanComments()
                var value: NSString?
                var node: NSDictionary?
                if scanAssignment(&value) {
                    accumulateValue(value!, forKey: key as! String)
                } else if scanNode(&node) {
                    accumulateValue(node!, forKey: key as! String)
                } else {
                    scanner.scanLocation = originalLocation
                    return false
                }
                scanComments()
            }

            result.memory = ret
            return true
        }

        scanComments()

        var key: NSString?
        guard scanKey(&key) else { return [:] }
        scanComments()

        var node: NSDictionary?
        guard scanNode(&node) else { return [:] }
        return [key!: node!]
    }

}
