//
//  AppDelegate.swift
//  HiIOS01TabBar
//
//  Created by 杨建祥 on 2023/1/14.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dependency = AppDependency.shared
    
    // MARK: - Lifecycle
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        self.dependency.application(application, entryDidFinishLaunchingWithOptions: launchOptions)
        self.dependency.initialScreen(with: &self.window)
        self.dependency.application(application, leaveDidFinishLaunchingWithOptions: launchOptions)
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.dependency.applicationDidBecomeActive(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.dependency.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.dependency.applicationWillEnterForeground(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.dependency.applicationWillTerminate(application)
    }
    
    // MARK: - URL
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        self.dependency.application(app, open: url, options: options)
    }
    
    // MARK: - userActivity
    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        self.dependency.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
}
