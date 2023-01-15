//
//  AppDependency.swift
//  HiIOS01TabBar
//
//  Created by 杨建祥 on 2023/1/14.
//

import UIKit
import HiIOS

final class AppDependency: HiIOS.AppDependency {

    static var shared = AppDependency()
    
    // MARK: - Initialize
    override func initialScreen(with window: inout UIWindow?) {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        self.window = window

        let reactor = TabBarReactor(self.provider, nil)
        let controller = TabBarController(self.navigator, reactor)
        self.window.rootViewController = controller
        self.window.makeKeyAndVisible()
    }
    
    // MARK: - Test
    override func test(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    }

    // MARK: - Setup
    override func setupUser() {
        
    }
    
    override func setupConfiguration() {
        
    }
    
    // MARK: - Lifecycle
    override func application(
        _ application: UIApplication,
        entryDidFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        super.application(application, entryDidFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(
        _ application: UIApplication,
        leaveDidFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) {
        super.application(application, leaveDidFinishLaunchingWithOptions: launchOptions)
    }
    
}
