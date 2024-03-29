//
//  AppDependency.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import QMUIKit
import RxSwift
import URLNavigator_Hi
import SwifterSwift

public var gDisposeBag = DisposeBag()

open class AppDependency {
    
    public let navigator: NavigatorProtocol
    public let provider: ProviderType
    public let disposeBag = DisposeBag()
    public var window: UIWindow!
    
    // MARK: - Initialize
    public init() {
        self.navigator = Navigator()
        self.provider = Provider()
    }
    
    open func initialScreen(with window: inout UIWindow?) {
        
    }
    
    // MARK: - Test
    open func test(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    }
    
    // MARK: - Update
    open func setupConfiguration() {
    }
    
    open func setupUser() {
    }
    
    // MARK: - Update
    open func updateConfiguration() {
    }
    
    open func updateUser() {
    }
    
    // MARK: - Lifecycle
    open func application(_ application: UIApplication, entryDidFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // 初始化
        Runtime.shared.work()
        Library.shared.setup()
        Appearance.shared.config()
        Router.shared.initialize(self.provider, self.navigator)
        // 设置
        self.setupConfiguration()
        self.setupUser()
        // 日志
        logger.print("运行环境: \(UIApplication.shared.inferredEnvironment)", module: .hiIOS)
        logger.print("设备型号: \(QMUIHelper.deviceName)", module: .hiIOS)
        logger.print("系统版本: \(UIDevice.current.systemVersion)", module: .hiIOS)
        logger.print("屏幕尺寸: \(UIScreen.main.bounds.size)", module: .hiIOS)
        logger.print("安全区域: \(safeArea)", module: .hiIOS)
        logger.print("状态栏(\(statusBarHeightConstant))|导航栏(\(navigationBarHeight))|标签栏(\(tabBarHeight))", module: .hiIOS)
    }
    
    open func application(_ application: UIApplication, leaveDidFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.updateConfiguration()
        self.updateUser()
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.test(launchOptions: launchOptions)
        }
#endif
    }
    
    open func applicationDidBecomeActive(_ application: UIApplication) {
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    open func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    open func applicationWillTerminate(_ application: UIApplication) {
    }
    
    // MARK: - URL
    open func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        true
    }
    
    // MARK: - Activity
    open func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        true
    }
    
}
