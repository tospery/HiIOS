//
//  DataType.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public struct Metric {
    
    public struct Tile {
        public static let spaceHeight       = 20.f
        public static let buttonHeight      = 44.f
        public static let cellHeight        = 50.f
        public static let titleFontSize     = 16.f
        public static let detailFontSize    = 14.f
        public static let margin = UIEdgeInsets.init(top: 10, left: 10, bottom: 5, right: 10)
        public static let padding = UIOffset.init(horizontal: 10, vertical: 8)
    }
    
}

public enum HiToastStyle: Int {
    case success
    case failure
    case warning
}

public enum HiPagingStyle: Int, Codable {
    case basic
    case navigationBar
    case pageViewController
}

public enum Localization: String, Codable {
    case chinese    = "zh-Hans"
    case english    = "en"
    
    public static let allValues = [chinese, english]
    
    public var preferredLanguages: [String]? {
        [self.rawValue]
    }
}
