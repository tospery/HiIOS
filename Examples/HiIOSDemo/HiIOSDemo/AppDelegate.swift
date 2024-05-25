//
//  AppDelegate.swift
//  HiIOSDemo
//
//  Created by 杨建祥 on 2024/5/8.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        self.window?.rootViewController = HomeViewController.init()
        self.window?.makeKeyAndVisible()
        return true
    }
}
