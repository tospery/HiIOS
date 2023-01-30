//
//  Theme.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import RxTheme

public let themeService = ThemeType.service(initial: .current)

/// 假设从白到黑值为：0~9
public protocol Theme {
    // 背景（light模式下永远是白色，如果要修改背景为另外的颜色，使用lightColor）
    var backgroundColor: UIColor { get }
    var foregroundColor: UIColor { get }
    var lightColor: UIColor { get }                             // 浅色
    var darkColor: UIColor { get }                              // 深色
    var primaryColor: UIColor { get }                           // 主色（如：红色）
    var secondaryColor: UIColor { get }                         // 次色（如：蓝色）
    var titleColor: UIColor { get }                             // 标题
    var bodyColor: UIColor { get }                              // 内容
    var headerColor: UIColor { get }                            // 头部
    var footerColor: UIColor { get }                            // 尾部
    var borderColor: UIColor { get }                            // 边框
    var spacerColor: UIColor { get }                            // 空隙
    var separatorColor: UIColor { get }                         // 分隔条
    var indicatorColor: UIColor { get }                         // 指示器
    var specialColors: [String: UIColor] { get }                // 特殊颜色
    var barStyle: UIBarStyle { get }
    var statusBarStyle: UIStatusBarStyle { get }
    var keyboardAppearance: UIKeyboardAppearance { get }
    var blurStyle: UIBlurEffect.Style { get }
    
    init(primaryColor: UIColor?, secondaryColor: UIColor?)
}

public protocol ThemeTypeCompatible {
    var theme: Theme { get }
}

public enum ThemeType: ThemeProvider {
    case light(primaryColor: UIColor?, secondaryColor: UIColor?)
    case dark(primaryColor: UIColor?, secondaryColor: UIColor?)

    public var isDark: Bool {
        switch self {
        case .dark: return true
        default: return false
        }
    }
    
    public var associatedObject: Theme {
        if let compatible = self as? ThemeTypeCompatible {
            return compatible.theme
        }
        return HiTheme(primaryColor: .blue, secondaryColor: .red)
    }
    
    public func change(primaryColor: UIColor? = nil, secondaryColor: UIColor? = nil, isToggle: Bool = false) {
        var theme: ThemeType
        switch self {
        case let .light(oldPrimaryColor, oldSecondaryColor):
            if isToggle {
                theme = ThemeType.dark(primaryColor: primaryColor ?? oldPrimaryColor, secondaryColor: secondaryColor ?? oldSecondaryColor)
            } else {
                theme = ThemeType.light(primaryColor: primaryColor ?? oldPrimaryColor, secondaryColor: secondaryColor ?? oldSecondaryColor)
            }
        case let .dark(oldPrimaryColor, oldSecondaryColor):
            if isToggle {
                theme = ThemeType.light(primaryColor: primaryColor ?? oldPrimaryColor, secondaryColor: secondaryColor ?? oldSecondaryColor)
            } else {
                theme = ThemeType.dark(primaryColor: primaryColor ?? oldPrimaryColor, secondaryColor: secondaryColor ?? oldSecondaryColor)
            }
        }
        theme.save()
        themeService.switch(theme)
    }
    
    public func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.isDark, forKey: Parameter.isDark)
        defaults.set(self.associatedObject.primaryColor.hexString, forKey: Parameter.primaryColor)
        defaults.set(self.associatedObject.secondaryColor.hexString, forKey: Parameter.secondaryColor)
        defaults.synchronize()
    }
    
    public static var current: ThemeType {
        let defaults = UserDefaults.standard
        let isDark = defaults.bool(forKey: Parameter.isDark)
        var primaryColor: UIColor?
        var secondaryColor: UIColor?
        if let string = defaults.string(forKey: Parameter.primaryColor),
           let value = UIColor.init(hexString: string) {
            primaryColor = value
        }
        if let string = defaults.string(forKey: Parameter.secondaryColor),
           let value = UIColor.init(hexString: string) {
            secondaryColor = value
        }
        let theme = isDark ? ThemeType.dark(primaryColor: primaryColor, secondaryColor: secondaryColor) : ThemeType.light(primaryColor: primaryColor, secondaryColor: secondaryColor)
        return theme
    }

}

struct HiTheme: Theme {
    let backgroundColor = UIColor.white
    let foregroundColor = UIColor.black
    let lightColor = UIColor(hex: 0xF6F6F6)!
    let darkColor = UIColor.darkGray
    var primaryColor = UIColor.blue
    var secondaryColor = UIColor.red
    let titleColor = UIColor(hex: 0x333333)!
    let bodyColor = UIColor(hex: 0x666666)!
    let headerColor = UIColor(hex: 0xD2D2D2)!
    let footerColor = UIColor(hex: 0xB2B2B2)!
    let borderColor = UIColor(hex: 0xE2E2E2)!
    let spacerColor = UIColor(hex: 0xF4F4F4)!
    let separatorColor = UIColor(hex: 0xE0E0E0)!
    let indicatorColor = UIColor.red
    let specialColors = [String: UIColor].init()
    let barStyle = UIBarStyle.default
    let statusBarStyle = UIStatusBarStyle.default
    let keyboardAppearance = UIKeyboardAppearance.light
    let blurStyle = UIBlurEffect.Style.extraLight
    
    init(primaryColor: UIColor?, secondaryColor: UIColor?) {
        if let primaryColor = primaryColor {
            self.primaryColor = primaryColor
        }
        if let secondaryColor = secondaryColor {
            self.secondaryColor = secondaryColor
        }
    }
}
