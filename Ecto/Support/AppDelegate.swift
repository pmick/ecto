//
//  AppDelegate.swift
//  Twitch
//
//  Created by Patrick Mick on 5/18/18.
//  Copyright © 2018 Patrick Mick. All rights reserved.
//

import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var window: UIWindow? = UIWindow()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = HomeViewController()
        window?.makeKeyAndVisible()

        return true
    }
}
