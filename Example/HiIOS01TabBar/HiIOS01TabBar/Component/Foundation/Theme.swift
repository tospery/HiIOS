//
//  Theme.swift
//  HiIOS01TabBar
//
//  Created by 杨建祥 on 2023/1/15.
//

import UIKit
import HiIOS

struct LightTheme: Theme {
    let backgroundColor = UIColor.white
    let foregroundColor = UIColor.black
    let lightColor = UIColor(hex: 0xF6F6F6)!
    let darkColor = UIColor.Material.grey900
    var primaryColor = UIColor.Material.blue700
    let secondaryColor = UIColor.green
    let titleColor = UIColor(hex: 0x333333)!
    let bodyColor = UIColor(hex: 0x666666)!
    let headerColor = UIColor(hex: 0xD2D2D2)!
    let footerColor = UIColor(hex: 0xB2B2B2)!
    let borderColor = UIColor(hex: 0xE2E2E2)!
    let spacerColor = UIColor(hex: 0xF4F4F4)!
    let separatorColor = UIColor(hex: 0xE0E0E0)!
    let indicatorColor = UIColor.Material.grey600
    let specialColors = [String: UIColor].init()
    let barStyle = UIBarStyle.default
    let statusBarStyle = UIStatusBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight
    
    init(color: UIColor?) {
        guard let color = color else { return }
        self.primaryColor = color
    }
}

struct DarkTheme: Theme {
    let backgroundColor = UIColor.Material.black
    let foregroundColor = UIColor.Material.white
    let lightColor = UIColor.Material.grey900
    let darkColor = UIColor.Material.grey100
    var primaryColor = UIColor.red
    let secondaryColor = UIColor.Material.red
    let titleColor = UIColor.Material.red
    let bodyColor = UIColor.Material.red
    let headerColor = UIColor(hex: 0xD2D2D2)!
    let footerColor = UIColor(hex: 0xD2D2D2)!
    let borderColor = UIColor.Material.red
    let spacerColor = UIColor(hex: 0xF4F4F4)!
    let separatorColor = UIColor.Material.red
    let indicatorColor = UIColor.Material.red
    let specialColors = [String: UIColor].init()
    let barStyle = UIBarStyle.default
    let statusBarStyle = UIStatusBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight
    
    init(color: UIColor?) {
        guard let color = color else { return }
        self.primaryColor = color
    }
}

extension ThemeType: ThemeTypeCompatible {
    public var theme: Theme {
        switch self {
        case let .light(color): return LightTheme.init(color: color)
        case let .dark(color): return DarkTheme.init(color: color)
        }
    }
}
