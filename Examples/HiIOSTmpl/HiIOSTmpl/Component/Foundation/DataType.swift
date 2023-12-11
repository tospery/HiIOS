//
//  DataType.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/4.
//

import Foundation
import HiIOS

enum TabBarKey {
    case event
    case favorite
    case personal
}

enum Page: String, Codable {
    case none
    case open
    case closed
    
    static let stateValues = [open, closed]
    
    var title: String? { nil }
    
}

enum Localization: String, CustomStringConvertible, Codable {
    case system     = "system"
    case chinese    = "zh-Hans"
    case english    = "en"
    
    static let allValues = [system, chinese, english]
    
    static var preferredLanguages: [String]? {
        Configuration.current?.localization.preferredLanguages
    }
    
    var preferredLanguages: [String]? {
        switch self {
        case .system: return nil
        default: return [self.rawValue]
        }
    }
    
    var description: String {
        switch self {
        case .system: return R.string(preferredLanguages: myLangs).localizable.followSystem()
        case .chinese: return R.string(preferredLanguages: myLangs).localizable.chinese()
        case .english: return R.string(preferredLanguages: myLangs).localizable.english()
        }
    }
}
