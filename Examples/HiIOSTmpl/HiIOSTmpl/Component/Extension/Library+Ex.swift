//
//  Library+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import IQKeyboardManagerSwift
import Toast_Swift
import RxSwift
import RxCocoa
import Umbrella
import HiIOS

extension Library: LibraryCompatible {
    
    public func mySetup() {
        self.basic()
        self.setupUmbrella()
        self.setupKeyboardManager()
        self.setupToast()
        self.umShare()
#if DEBUG
#else
        self.aliyunAnalytics()
        self.aliyunCrash()
        self.aliyunPerformance()
        self.aliyunLog()
#endif
    }
    
    func setupUmbrella() {
        // analytics.register(provider: AliyunProvider.init())
    }
    
    func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
    }

    func setupToast() {
        themeService.typeStream
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { _ in
                ToastManager.shared.position = .top
                ToastManager.shared.isQueueEnabled = true
                var style = ToastStyle.init()
                style.cornerRadius = -1
                style.backgroundColor = .secondary
                style.messageFont = .normal(15)
                ToastManager.shared.style = style
            })
            .disposed(by: self.disposeBag)
    }
    
    func umShare() {
//        UMConfigure.initWithAppkey(
//            Platform.umeng.appKey,
//            channel: UIApplication.shared.inferredEnvironment.description
//        )
//        UMSocialGlobal.shareInstance().universalLinkDic = [
//            UMSocialPlatformType.QQ.rawValue: Platform.qq.appLink
//        ]
//        UMSocialManager.default().setPlaform(.QQ, appKey: Platform.qq.appId, appSecret: nil, redirectURL: nil)
    }
    
    func aliyunAnalytics() {
//        ALBBMANAnalytics.getInstance()?.autoInit()
//        ALBBMANAnalytics.getInstance()?.setAppVersion(UIApplication.shared.version!)
//        ALBBMANAnalytics.getInstance()?.setChannel(UIApplication.shared.inferredEnvironment.description)
    }
    
    func aliyunCrash() {
//        let provider = AlicloudCrashProvider.init()
//        provider.autoInit(
//            withAppVersion: UIApplication.shared.version!,
//            channel: UIApplication.shared.inferredEnvironment.description,
//            nick: UIDevice.current.uuid
//        )
//        AlicloudHAProvider.start()
    }
    
    func aliyunPerformance() {
//        let provider = AlicloudAPMProvider.init()
//        provider.autoInit(
//            withAppVersion: UIApplication.shared.version!,
//            channel: UIApplication.shared.inferredEnvironment.description,
//            nick: UIDevice.current.uuid
//        )
//        AlicloudHAProvider.start()
    }
    
    func aliyunLog() {
//        let provider = AlicloudTlogProvider.init()
//        provider.autoInit(
//            withAppVersion: UIApplication.shared.version!,
//            channel: UIApplication.shared.inferredEnvironment.description,
//            nick: UIDevice.current.uuid
//        )
//        AlicloudHAProvider.start()
//        TRDManagerService.update(.info)
    }

}
