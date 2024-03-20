//
//  DataType.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

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
    case system     = "system"
    case chinese    = "zh-Hans"
    case english    = "en"
    
    public static let allValues = [system, chinese, english]
    
//    static var preferredLanguages: [String]? {
//        Configuration.current?.localization.preferredLanguages
//    }
    
    public var preferredLanguages: [String]? {
        switch self {
        case .system: return nil
        default: return [self.rawValue]
        }
    }
    
//    var description: String {
//        switch self {
//        case .system: return R.string.localizable.followSystem(
//            preferredLanguages: myLangs
//        )
//        case .chinese: return R.string.localizable.chinese(
//            preferredLanguages: myLangs
//        )
//        case .english: return R.string.localizable.english(
//            preferredLanguages: myLangs
//        )
//        }
//    }
}

// MARK: - 联合类型
// public typealias KVTuple = (key: Any, value: Any?)
// public typealias HiContent = (header: ModelType?, models: [ModelType])
// public typealias CustomLoginResult = (handled: Bool, result: Bool)
