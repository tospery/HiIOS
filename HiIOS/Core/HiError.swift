//
//  HiError.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

//        NSURLErrorTimedOut(-1001): 请求超时
//        NSURLErrorCannotConnectToHost(-1004): 找不到服务
//        NSURLErrorDataNotAllowed(-1020): 网络不可用
public struct ErrorCode {
    public static let ok                        = 200
    public static let serverUnableConnect       = -10001
    public static let serverInternalError       = -10002
    public static let serverNoResponse          = -10003
    public static let nserror                   = -20001
    public static let skerror                   = -20002
    public static let rxerror                   = -20003
    public static let aferror                   = -20004
    public static let moyaError                 = -20005
    public static let asError                   = -20006
    public static let appError                  = -30000
}

public enum HiError: Error {
    /// 仅用于导航的手动退回
    case none
    case unknown
    case timeout
    case navigation
    case dataInvalid
    case listIsEmpty
    case networkNotConnected
    case networkNotReachable
    case userNotLoginedIn   // 对应HTTP的401
    case userLoginExpired   // 对应HTTP的403
    case server(Int, String?, [String: Any]?)
    case app(Int, String?, [String: Any]?)
}

extension HiError: CustomNSError {
    public static let domain = Bundle.main.bundleIdentifier ?? ""
    public var errorCode: Int {
        switch self {
        case .none: return 0
        case .unknown: return 1
        case .timeout: return 2
        case .navigation: return 3
        case .dataInvalid: return 4
        case .listIsEmpty: return 5
        case .networkNotConnected: return 6
        case .networkNotReachable: return 7
        case .userNotLoginedIn: return 8
        case .userLoginExpired: return 9
        case let .server(code, _, _): return code
        case let .app(code, _, _): return code
        }
    }
}

extension HiError: LocalizedError {
    /// 概述
    public var failureReason: String? {
        switch self {
        case .none:
            return NSLocalizedString("Error.None.Title", value: "", comment: "")
        case .unknown:
            return NSLocalizedString("Error.Unknown.Title", value: "", comment: "")
        case .timeout:
            return NSLocalizedString("Error.Timeout.Title", value: "", comment: "")
        case .navigation:
            return NSLocalizedString("Error.Navigation.Title", value: "", comment: "")
        case .dataInvalid:
            return NSLocalizedString("Error.DataInvalid.Title", value: "", comment: "")
        case .listIsEmpty:
            return NSLocalizedString("Error.ListIsEmpty.Title", value: "", comment: "")
        case .networkNotConnected:
            return NSLocalizedString("Error.Network.NotConnected.Title", value: "", comment: "")
        case .networkNotReachable:
            return NSLocalizedString("Error.Network.NotReachable.Title", value: "", comment: "")
        case .userNotLoginedIn:
            return NSLocalizedString("Error.User.NotLoginedIn.Title", value: "", comment: "")
        case .userLoginExpired:
            return NSLocalizedString("Error.User.LoginExpired.Title", value: "", comment: "")
        case let .server(code, _, _):
            return NSLocalizedString("Error.Server.Title\(code)", value: "", comment: "")
        case let .app(code, _, _):
            return NSLocalizedString("Error.App.Title\(code)", value: "", comment: "")
        }
    }
    /// 详情
    public var errorDescription: String? {
        switch self {
        case .none:
            return NSLocalizedString("Error.None.Message", value: "", comment: "")
        case .unknown:
            return NSLocalizedString("Error.Unknown.Message", value: "", comment: "")
        case .timeout:
            return NSLocalizedString("Error.Timeout.Message", value: "", comment: "")
        case .navigation:
            return NSLocalizedString("Error.Navigation.Message", value: "", comment: "")
        case .dataInvalid:
            return NSLocalizedString("Error.DataInvalid.Message", value: "", comment: "")
        case .listIsEmpty:
            return NSLocalizedString("Error.ListIsEmpty.Message", value: "", comment: "")
        case .networkNotConnected:
            return NSLocalizedString("Error.Network.NotConnected.Message", value: "", comment: "")
        case .networkNotReachable:
            return NSLocalizedString("Error.Network.NotReachable.Message", value: "", comment: "")
        case .userNotLoginedIn:
            return NSLocalizedString("Error.User.NotLoginedIn.Message", value: "", comment: "")
        case .userLoginExpired:
            return NSLocalizedString("Error.User.LoginExpired.Message", value: "", comment: "")
        case let .server(code, message, _):
            return message ?? NSLocalizedString("Error.Server.Message\(code)", value: "", comment: "")
        case let .app(code, message, _):
            return message ?? NSLocalizedString("Error.App.Message\(code)", value: "", comment: "")
        }
    }
    /// 重试
    public var recoverySuggestion: String? {
        var suggestion: String?
        switch self {
        case let .app(code, _, _):
            suggestion = NSLocalizedString("Error.App.Suggestion\(code)", value: "", comment: "")
        default:
            break
        }
        if suggestion?.hasPrefix("Error.") ?? false {
            suggestion = nil
        }
        return suggestion
    }
}

extension HiError: Equatable {
    public static func == (lhs: HiError, rhs: HiError) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.unknown, .unknown),
            (.timeout, .timeout),
             (.navigation, .navigation),
             (.dataInvalid, .dataInvalid),
             (.listIsEmpty, .listIsEmpty),
            (.networkNotConnected, .networkNotConnected),
            (.networkNotReachable, .networkNotReachable),
            (.userNotLoginedIn, .userNotLoginedIn),
           (.userLoginExpired, .userLoginExpired):
            return true
        case (.server(let left, _, _), .server(let right, _, _)),
             (.app(let left, _, _), .app(let right, _, _)):
            return left == right
        default: return false
        }
    }
}

extension HiError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none: return "HiError.none"
        case .unknown: return "HiError.unknown"
        case .timeout: return "HiError.timeout"
        case .navigation: return "HiError.navigation"
        case .dataInvalid: return "HiError.dataInvalid"
        case .listIsEmpty: return "HiError.listIsEmpty"
        case .networkNotConnected: return "HiError.networkNotConnected"
        case .networkNotReachable: return "HiError.networkNotReachable"
        case .userNotLoginedIn: return "HiError.userNotLoginedIn"
        case .userLoginExpired: return "HiError.userLoginExpired"
        case let .server(code, message, extra): return "HiError.server(\(code), \(message ?? ""), \(extra?.jsonString() ?? "")"
        case let .app(code, message, extra): return "HiError.app(\(code), \(message ?? ""), \(extra?.jsonString() ?? ""))"
        }
    }
}

extension HiError {
    
    public var isNetwork: Bool {
        self == .networkNotConnected || self == .networkNotReachable
    }

//    public var isServer: Bool {
//        if case .server = self {
//            return true
//        }
//        return false
//    }
//
//    public var isCancel: Bool {
//        self == .cancel
//    }
//
//    public var isListIsEmpty: Bool {
//        self == .dataIsEmpty
//    }

    public var isNeedLogin: Bool {
        self == .userNotLoginedIn || self == .userLoginExpired
    }
    
    public func isServerError(withCode errorCode: Int) -> Bool {
        if case let .server(code, _, _) = self {
            return errorCode == code
        }
        return false
    }
    
    public func isAppError(withCode errorCode: Int) -> Bool {
        if case let .app(code, _, _) = self {
            return errorCode == code
        }
        return false
    }
    
}

public protocol HiErrorCompatible {
    var hiError: HiError { get }
}

extension Error {
    
    public var asHiError: HiError {
        if let hi = self as? HiError {
            return hi
        }
        
        if let compatible = self as? HiErrorCompatible {
            return compatible.hiError
        }
        return .server(0, self.localizedDescription, nil)
    }

}
