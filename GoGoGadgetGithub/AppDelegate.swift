//
//  AppDelegate.swift
//  GoGoGadgetGithub
//
//  Created by Jeremy Moore on 6/27/16.
//  Copyright © 2016 Jeremy Moore. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        print("AppDelegate - \(url)")
        
        GithubOAuth.shared.tokenRequestWithCallback(url, options: SaveOptions.userDefaults) { (success) in
            
            if success {
                print("Yay!! Token!!")
            }
        }
        return true
    }

    
}