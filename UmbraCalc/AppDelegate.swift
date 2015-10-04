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
        if !Crew.existsInContext(managedObjectContext) {
            [
                ("Jebediah", Crew.pilotTitle),
                ("Bill", Crew.engineerTitle),
                ("Bob", Crew.scientistTitle),
                ("Valentina", Crew.pilotTitle)
                ].forEach {
                    _ = try? Crew(insertIntoManagedObjectContext: managedObjectContext).withName($0.0).withCareer($0.1)
            }
        }

        let split = window!.rootViewController as! UISplitViewController
        let navigationController = split.viewControllers.first as! UINavigationController
        let master = navigationController.viewControllers.first as! MasterTableViewController

        split.preferredDisplayMode = .AllVisible
        split.delegate = master
        master.managedObjectContext = coreDataStack.managedObjectContext

        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        coreDataStack.saveContext()
    }

    func applicationWillResignActive(application: UIApplication) {
        coreDataStack.saveContext()
    }

}
