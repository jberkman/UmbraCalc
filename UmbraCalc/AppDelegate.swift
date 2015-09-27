//
//  AppDelegate.swift
//  UmbraCalc
//
//  Created by jacob berkman on 2015-09-23.
//  Copyright © 2015 jacob berkman.
//
//  Based on and includes portions of Moduler Kolonization System by RoverDude
//  https://github.com/BobPalmer/MKS/
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial
//  4.0 International License. To view a copy of this license, visit
//  http://creativecommons.org/licenses/by-nc/4.0/.
//

import UIKit

@UIApplicationMain
class AppDelegate: NSObject {

    var window: UIWindow?
    private lazy var coreDataStack: CoreDataStack = CoreDataStack()

}

extension AppDelegate: UIApplicationDelegate {

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        (1 ... 10).forEach {
            coreDataStack.insertKolony()!.withName("Kolony \($0)")
            coreDataStack.insertStation()!.withName("Station \($0)")
        }
        coreDataStack.insertCrew()!.withName("Jebediah").withCareer(Crew.pilotTitle).withStarCount(1)
        coreDataStack.insertCrew()!.withName("Bill").withCareer(Crew.engineerTitle).withStarCount(2)
        coreDataStack.insertCrew()!.withName("Bob").withCareer(Crew.scientistTitle).withStarCount(3)
        coreDataStack.insertCrew()!.withName("Valentina").withCareer(Crew.pilotTitle).withStarCount(4)
        guard let tabBar = window?.rootViewController as? UITabBarController else { return false }
        tabBar.setManagingObjectContext(coreDataStack)
        tabBar.viewControllers?.forEach {
            guard let split = $0 as? UISplitViewController else { return }
            split.preferredDisplayMode = .AllVisible
            split.delegate = ((split.viewControllers.first as? UINavigationController)?.viewControllers.first as? UISplitViewControllerDelegate) ?? self
        }
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillResignActive(application: UIApplication) {
        coreDataStack.saveContext()
    }

}

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        print(__FUNCTION__, splitViewController, secondaryViewController, primaryViewController)
        return secondaryViewController is EmptyDetailViewController
    }

    func splitViewController(splitViewController: UISplitViewController, separateSecondaryViewControllerFromPrimaryViewController primaryViewController: UIViewController) -> UIViewController? {
        print(__FUNCTION__, splitViewController, primaryViewController)
        return nil
    }

}
