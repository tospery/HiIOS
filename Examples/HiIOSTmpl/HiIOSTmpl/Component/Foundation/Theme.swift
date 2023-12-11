//
//  Theme.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/4.
//

import UIKit
import HiIOS

struct LightTheme: Theme {
    let backgroundColor = UIColor.white
    let foregroundColor = UIColor.black
    let lightColor = UIColor(hex: 0xF6F6F6)!
    let darkColor = UIColor.Material.grey900
    var primaryColor = ColorTheme.red.primaryColor
    var secondaryColor = ColorTheme.red.secondaryColor
    let titleColor = UIColor(hex: 0x333333)!
    let bodyColor = UIColor(hex: 0x666666)!
    let headerColor = UIColor(hex: 0xD2D2D2)!
    let footerColor = UIColor(hex: 0xB2B2B2)!
    let borderColor = UIColor(hex: 0xE2E2E2)!
    let spacerColor = UIColor(hex: 0xF4F4F4)!
    let separatorColor = UIColor(hex: 0xE0E0E0)!
    let indicatorColor = UIColor.Material.grey600
    let specialColors = [
        Parameter.error: UIColor.red
    ]
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

struct DarkTheme: Theme {
    let backgroundColor = UIColor.Material.black
    let foregroundColor = UIColor.Material.white
    let lightColor = UIColor.Material.grey900
    let darkColor = UIColor.Material.grey100
    var primaryColor = UIColor.red
    var secondaryColor = UIColor.Material.red
    let titleColor = UIColor.Material.red
    let bodyColor = UIColor.Material.red
    let headerColor = UIColor(hex: 0xD2D2D2)!
    let footerColor = UIColor(hex: 0xD2D2D2)!
    let borderColor = UIColor.Material.red
    let spacerColor = UIColor(hex: 0xF4F4F4)!
    let separatorColor = UIColor.Material.red
    let indicatorColor = UIColor.Material.red
    let specialColors = [
        Parameter.error: UIColor.red
    ]
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

extension ThemeType: ThemeTypeCompatible {
    public var theme: Theme {
        switch self {
        case let .light(primaryColor, secondaryColor):
            return LightTheme(primaryColor: primaryColor, secondaryColor: secondaryColor)
        case let .dark(primaryColor, secondaryColor):
            return DarkTheme(primaryColor: primaryColor, secondaryColor: secondaryColor)
        }
    }
}

enum ColorTheme: Int, CustomStringConvertible, Codable {
    case red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green,
         lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray

    static let allValues = [
        red, pink, purple, deepPurple, indigo, blue, lightBlue, cyan, teal, green,
        lightGreen, lime, yellow, amber, orange, deepOrange, brown, gray, blueGray
    ]

    var primaryColor: UIColor {
        switch self {
        case .red: return UIColor.Material.red
        case .pink: return UIColor.Material.pink
        case .purple: return UIColor.Material.purple
        case .deepPurple: return UIColor.Material.deepPurple
        case .indigo: return UIColor.Material.indigo
        case .blue: return UIColor.Material.blue
        case .lightBlue: return UIColor.Material.lightBlue
        case .cyan: return UIColor.Material.cyan
        case .teal: return UIColor.Material.teal
        case .green: return UIColor.Material.green
        case .lightGreen: return UIColor.Material.lightGreen
        case .lime: return UIColor.Material.lime
        case .yellow: return UIColor.Material.yellow
        case .amber: return UIColor.Material.amber
        case .orange: return UIColor.Material.orange
        case .deepOrange: return UIColor.Material.deepOrange
        case .brown: return UIColor.Material.brown
        case .gray: return UIColor.Material.grey
        case .blueGray: return UIColor.Material.blueGrey
        }
    }

    var secondaryColor: UIColor {
        switch self {
        case .red: return UIColor.Material.red900
        case .pink: return UIColor.Material.pink900
        case .purple: return UIColor.Material.purple900
        case .deepPurple: return UIColor.Material.deepPurple900
        case .indigo: return UIColor.Material.indigo900
        case .blue: return UIColor.Material.blue900
        case .lightBlue: return UIColor.Material.lightBlue900
        case .cyan: return UIColor.Material.cyan900
        case .teal: return UIColor.Material.teal900
        case .green: return UIColor.Material.green900
        case .lightGreen: return UIColor.Material.lightGreen900
        case .lime: return UIColor.Material.lime900
        case .yellow: return UIColor.Material.yellow900
        case .amber: return UIColor.Material.amber900
        case .orange: return UIColor.Material.orange900
        case .deepOrange: return UIColor.Material.deepOrange900
        case .brown: return UIColor.Material.brown900
        case .gray: return UIColor.Material.grey900
        case .blueGray: return UIColor.Material.blueGrey900
        }
    }
    
    var description: String {
        switch self {
        case .red: return "Red"
        case .pink: return "Pink"
        case .purple: return "Purple"
        case .deepPurple: return "Deep Purple"
        case .indigo: return "Indigo"
        case .blue: return "Blue"
        case .lightBlue: return "Light Blue"
        case .cyan: return "Cyan"
        case .teal: return "Teal"
        case .green: return "Green"
        case .lightGreen: return "Light Green"
        case .lime: return "Lime"
        case .yellow: return "Yellow"
        case .amber: return "Amber"
        case .orange: return "Orange"
        case .deepOrange: return "Deep Orange"
        case .brown: return "Brown"
        case .gray: return "Gray"
        case .blueGray: return "Blue Gray"
        }
    }
    
}
