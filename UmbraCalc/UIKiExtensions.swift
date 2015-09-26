//
//  UIKitExtensions.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-26.
//  Copyright © 2015 jacob berkman. All rights reserved.
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
