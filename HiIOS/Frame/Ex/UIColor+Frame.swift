//
//  UIColor+Frame.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import SwifterSwift

public extension UIColor {
    
    static var background: UIColor {
        themeService.type.associatedObject.backgroundColor
    }

    static var foreground: UIColor {
        themeService.type.associatedObject.foregroundColor
    }

    static var light: UIColor {
        themeService.type.associatedObject.lightColor
    }
    
    static var dark: UIColor {
        themeService.type.associatedObject.darkColor
    }

    static var primary: UIColor {
        themeService.type.associatedObject.primaryColor
    }

    static var secondary: UIColor {
        themeService.type.associatedObject.secondaryColor
    }

    static var title: UIColor {
        themeService.type.associatedObject.titleColor
    }

    static var body: UIColor {
        themeService.type.associatedObject.bodyColor
    }
    
    static var header: UIColor {
        themeService.type.associatedObject.headerColor
    }

    static var footer: UIColor {
        themeService.type.associatedObject.footerColor
    }

    static var border: UIColor {
        themeService.type.associatedObject.borderColor
    }
    
    static var spacer: UIColor {
        themeService.type.associatedObject.spacerColor
    }

    static var separator: UIColor {
        themeService.type.associatedObject.separatorColor
    }

    static var indicator: UIColor {
        themeService.type.associatedObject.indicatorColor
    }
    
    static func special(with key: String) -> UIColor? {
        themeService.type.associatedObject.specialColors[key]
    }
    
    func image(size: CGSize = .init(100)) -> UIImage {
        return .init(color: self, size: size)
    }
    
}
