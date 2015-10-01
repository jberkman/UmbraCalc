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
        guard let managedObjectContext = coreDataStack.managedObjectContext else { return false }
        (1 ... 10).forEach {
            _ = try? Kolony(insertIntoManagedObjectContext: managedObjectContext).withName("Kolony \($0)")
            _ = try? Station(insertIntoManagedObjectContext: managedObjectContext).withName("Station \($0)")
        }
        _ = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withName("Jebediah").withCareer(Crew.pilotTitle).withStarCount(1)
        _ = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withName("Bill").withCareer(Crew.engineerTitle).withStarCount(2)
        _ = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withName("Bob").withCareer(Crew.scientistTitle).withStarCount(3)
        _ = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withName("Valentina").withCareer(Crew.pilotTitle).withStarCount(4)

        guard let split = window?.rootViewController as? UISplitViewController,
            navigationController = split.viewControllers.first as? UINavigationController,
            master = navigationController.viewControllers.first as? UISplitViewControllerDelegate else { return false }

        split.preferredDisplayMode = .AllVisible
        split.delegate = master
        split.setManagingObjectContext(coreDataStack)
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillResignActive(application: UIApplication) {
        coreDataStack.saveContext()
    }

}
