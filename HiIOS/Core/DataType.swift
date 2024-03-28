//
//  DataType.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public struct Metric {
    
    public struct Simple {
        public static let spaceHeight       = 20.f
        public static let buttonHeight      = 44.f
        public static let cellHeight        = 50.f
        public static let titleFontSize     = 16.f
        public static let detailFontSize    = 14.f
        public static let margin = UIEdgeInsets.init(top: 10, left: 20, bottom: 5, right: 5)
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

/// 导航的分类
public enum JumpType: Int {
    /// 前进
    case forward
    /// 后退
    case back
}

/// 前进的分类 -> hiios://[host]?forwardType=0
public enum ForwardType: Int {
    /// 推进
    case push
    /// 展示
    case present
    /// 打开
    case open
}

/// 后退的分类 -> hiios://back?backType=0
public enum BackType: Int {
    /// 自动
    case auto
    /// 弹出（一个）
    case popOne
    /// 弹出（所有）
    case popAll
    /// 退场
    case dismiss
}

/// 打开的分类 -> hiios://[popup|sheet|alert|toast]/[path]
public enum OpenType: Int {
    /// 消息框（自动关闭）
    case toast
    /// 提示框（可选择的）
    case alert
    /// 表单框（可操作的）
    case sheet
    /// 弹窗
    case popup
    /// 登录（因为登录页通常需要自定义，故以打开方式处理）
    case login
    
    static let allHosts = [
        Router.Host.toast,
        Router.Host.alert,
        Router.Host.sheet,
        Router.Host.popup,
        Router.Host.login
    ]
}

// MARK: - 联合类型
// public typealias KVTuple = (key: Any, value: Any?)
// public typealias HiContent = (header: ModelType?, models: [ModelType])
// public typealias CustomLoginResult = (handled: Bool, result: Bool)
