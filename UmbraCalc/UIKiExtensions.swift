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

enum SegueIdentifier: String {
    case Edit = "edit"
    case Insert = "insert"
    case View = "view"
}

extension UIStoryboardSegue {

    var segueIdentifier: SegueIdentifier? {
        guard let identifier = identifier else { return nil }
        return SegueIdentifier(rawValue: identifier)
    }

    func destinationViewControllerWithType<ViewController: UIViewController>() -> ViewController? {
        return destinationViewController as? ViewController ??
            (destinationViewController as? UINavigationController)?.viewControllers.first as? ViewController
    }

}

extension UITableView {

    func indexPathForSegueSender(sender: AnyObject?) -> NSIndexPath? {
        return sender is UITableViewCell ? indexPathForCell(sender as! UITableViewCell) : sender as? NSIndexPath
    }

}
