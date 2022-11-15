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
    
    init(color: UIColor?)
}

public protocol ThemeTypeCompatible {
    var theme: Theme { get }
}

public enum ThemeType: ThemeProvider {
    case light(color: UIColor?)
    case dark(color: UIColor?)

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
        fatalError()
    }
    
    public func toggle(_ color: UIColor? = nil) {
        var theme: ThemeType
        if let color = color {
            switch self {
            case .light: theme = ThemeType.dark(color: color)
            case .dark: theme = ThemeType.light(color: color)
            }
        } else {
            switch self {
            case .light(let color): theme = ThemeType.dark(color: color)
            case .dark(let color): theme = ThemeType.light(color: color)
            }
        }
        theme.save()
        themeService.switch(theme)
    }
    
    public func save() {
        let defaults = UserDefaults.standard
        defaults.set(self.isDark, forKey: Parameter.isDark)
        defaults.set(self.associatedObject.primaryColor.hexString, forKey: Parameter.primaryColor)
        defaults.synchronize()
    }
    
    public static var current: ThemeType {
        let defaults = UserDefaults.standard
        let isDark = defaults.bool(forKey: Parameter.isDark)
        var color: UIColor?
        if let string = defaults.string(forKey: Parameter.primaryColor),
           let value = UIColor.init(hexString: string) {
            color = value
        }
        let theme = isDark ? ThemeType.dark(color: color) : ThemeType.light(color: color)
        return theme
    }

}
