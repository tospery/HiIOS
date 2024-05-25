//
//  AppDependency.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import RxSwift
import URLNavigator_Hi
import SwifterSwift
import RxRelay
import HiCore
import HiNav
import HiDomain

public var gDisposeBag = DisposeBag()
public let profileService = BehaviorRelay<(any ProfileType)?>(value: nil)

open class AppDependency {
    
    public let navigator: NavigatorProtocol
    public var provider: ProviderProtocol!
    public let disposeBag = DisposeBag()
    public var window: UIWindow!
    
    // MARK: - Initialize
    public init() {
        self.navigator = Navigator()
        // self.provider = Provider()
    }
    
    open func initialScreen(with window: inout UIWindow?) {
        
    }
    
    // MARK: - Test
    open func test(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
    }
    
    // MARK: - setup
    open func setupData() {
//        profileService
//            .distinctUntilChanged { HiCore.compareAny($0, $1) }
//            .subscribe(onNext: { profileType in
//                appLanguageCodes = profileType?.localization?.preferredLanguages
//            })
//            .disposed(by: self.disposeBag)
        self.setupConfiguration()
        self.setupUser()
    }
    
    open func setupConfiguration() {
    }
    
    open func setupUser() {
    }
    
    // MARK: - Update
    open func updateData() {
        self.updateConfiguration()
        self.updateUser()
    }
    
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
        HiNav.shared.initialize(self.provider, self.navigator)
        // 设置
        self.setupData()
        // 日志
        logger.print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "", module: .hiIOS)
        logger.print("运行环境: \(UIApplication.shared.inferredEnvironment)", module: .hiIOS)
        logger.print("设备型号: \(UIDevice.current.modelName)", module: .hiIOS)
        logger.print("硬件标识: \(UIDevice.current.uuid)", module: .hiIOS)
        logger.print("系统版本: \(UIDevice.current.systemVersion)", module: .hiIOS)
        logger.print("屏幕尺寸: \(UIScreen.main.bounds.size)", module: .hiIOS)
        logger.print("安全区域: \(safeArea)", module: .hiIOS)
        logger.print("状态栏(\(statusBarHeightConstant))|导航栏(\(navigationBarHeight))|标签栏(\(tabBarHeight))", module: .hiIOS)
    }
    
    open func application(_ application: UIApplication, leaveDidFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.updateData()
#if DEBUG
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
