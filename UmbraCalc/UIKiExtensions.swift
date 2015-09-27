//
//  UIKitExtensions.swift
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

import CoreData
import UIKit

extension UINavigationController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        (topViewController as? ManagingObjectContextContainer)?.setManagingObjectContext(managingObjectContext)
    }

}

extension UITabBarController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        viewControllers?.forEach { ($0 as? ManagingObjectContextContainer)?.setManagingObjectContext(managingObjectContext) }
    }

}

extension UISplitViewController: ManagingObjectContextContainer {

    func setManagingObjectContext(managingObjectContext: ManagingObjectContext) {
        viewControllers.forEach { ($0 as? ManagingObjectContextContainer)?.setManagingObjectContext(managingObjectContext) }
    }

}
