//
//  AppDelegate.swift
//  EmailPresenter
//
//  Created by Tyson on 2018-08-21.
//  Copyright © 2018 Sprout Yard. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = .white
        self.window = window

        window.rootViewController = ComposeViewController()

        window.makeKeyAndVisible()

        return true
    }
}

