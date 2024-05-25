//
//  Appearance.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import RxSwift
import HiCore

import HiTheme
import HiNav

public protocol AppearanceCompatible {
    func myConfig()
}

final public class Appearance {
    
    public let disposeBag = DisposeBag()
    
    public static var shared = Appearance()
    
    public init() {
    }
    
    public func config() {
        if let compatible = self as? AppearanceCompatible {
            compatible.myConfig()
        } else {
            self.basic()
        }
    }
    
    public func basic() {
        // NavBar
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance.init()
            appearance.configureWithOpaqueBackground()
            appearance.theme.backgroundColor = themeService.attribute { $0.lightColor }
            appearance.shadowImage = UIImage.init()
            appearance.shadowColor = nil
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.background,
                .font: UIFont.bold(17)
            ]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().theme.backgroundColor = themeService.attribute { $0.lightColor }
            UINavigationBar.appearance().titleTextAttributes = [
                .foregroundColor: UIColor.background,
                .font: UIFont.bold(17)
            ]
        }
        
        // TabBar
        if #available(iOS 13.0, *) {
            let appearance = UITabBarAppearance.init()
            appearance.configureWithOpaqueBackground()
            appearance.theme.backgroundColor = themeService.attribute { $0.lightColor }
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        } else {
            UITabBar.appearance().isTranslucent = false
            UITabBar.appearance().theme.backgroundColor = themeService.attribute { $0.lightColor }
        }
    }
    
}

