//
//  Notification+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit

public extension Notification.Name {
    
    static let ThemeChanged = Notification.Name(UIApplication.shared.bundleIdentifier + ".themechanged")

}
