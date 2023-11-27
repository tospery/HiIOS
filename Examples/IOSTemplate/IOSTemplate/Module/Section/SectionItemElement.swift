//
//  SectionItemValue.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2022/10/3.
//

import Foundation

enum SectionItemElement {
    case settings, about
    case banner([String])

    static let aboutSections = [[settings], [about]]
}

extension SectionItemElement: CustomStringConvertible {
    var description: String {
        switch self {
        case .settings: return "settings"
        case .about: return "about"
        case .banner: return "banner"
        }
    }
}
