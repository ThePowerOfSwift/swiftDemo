//
//  AppDelegate.swift
//  Demo
//
//  Created by GUANJIU ZHANG on 9/25/16.
//

// Application Life Cycle

//Subclassing

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
    
        return true
    }

}

