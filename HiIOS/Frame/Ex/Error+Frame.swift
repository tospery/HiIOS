//
//  Error+Frame.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import RxSwift
import Alamofire
import SwifterSwift_Hi
import Moya
import SafariServices
import AuthenticationServices
import StoreKit

extension HiError {

    public var displayImage: UIImage? {
        switch self {
        case .networkNotConnected, .networkNotReachable: return UIImage.networkError
        case .server: return UIImage.serverError
        case .dataIsEmpty: return UIImage.emptyError
        case .userNotLoginedIn: return UIImage.userNotLoginedInError
        case .userLoginExpired: return UIImage.userLoginExpiredError
        default: return nil
        }
    }
    
}

extension NSError: HiErrorCompatible {
    public var hiError: HiError {
        logger.print("NSError转换-> \(self.domain), \(self.code), \(self.localizedDescription)", module: .hiIOS)
        
        if #available(iOS 12.0, *) {
            if self.domain == ASWebAuthenticationSessionError.errorDomain {
                if let compatible = self as? ASWebAuthenticationSessionError {
                    return compatible.hiError
                }
            }
        }
        
        if self.domain == SFAuthenticationError.errorDomain {
            if let compatible = self as? SFAuthenticationError {
                return compatible.hiError
            }
        }
        if self.domain == SKError.errorDomain {
            if let compatible = self as? SKError {
                return compatible.hiError
            }
        }
        if self.domain == NSURLErrorDomain {
            // NSURLErrorDomain Code=-1020 "目前不允许数据连接。"
            // NSURLErrorUnknown                        -1
            // NSURLErrorCancelled                      -999
            // NSURLErrorBadURL                         -1000
            // NSURLErrorTimedOut                       -1001(请求超时)
            // NSURLErrorUnsupportedURL                 -1002
            // NSURLErrorCannotFindHost                 -1003
            // NSURLErrorCannotConnectToHost            -1004(无法连接服务器)
            // NSURLErrorNetworkConnectionLost          -1005
            // NSURLErrorDNSLookupFailed                -1006
            // NSURLErrorHTTPTooManyRedirects           -1007
            // NSURLErrorResourceUnavailable            -1008
            // NSURLErrorNotConnectedToInternet         -1009(似乎已断开与互联网的连接)
            // NSURLErrorRedirectToNonExistentLocation  -1010
            // NSURLErrorBadServerResponse              -1011
            // NSURLErrorUserCancelledAuthentication    -1012
            // NSURLErrorUserAuthenticationRequired     -1013
            // NSURLErrorZeroByteResource               -1014
            // NSURLErrorCannotDecodeRawData            -1015
            // NSURLErrorCannotDecodeContentData        -1016
            // NSURLErrorCannotParseResponse            -1017
            // -1202（此服务器的证书无效。）
            // logger.print("看看错误码: \(NSURLErrorFileDoesNotExist)")

            if self.code == -1020 {
                return .networkNotConnected
            }
            if self.code >= NSURLErrorNetworkConnectionLost &&
                self.code <= NSURLErrorCancelled {
                return .server(ErrorCode.serverUnableConnect, self.localizedDescription, nil)
            }
            if self.code == NSURLErrorCannotParseResponse {
                return .dataInvalid
            }
//            if self.code >= NSURLErrorDNSLookupFailed ||
//                        self.code <= NSURLErrorCannotParseResponse {
//                return .server(ErrorCode.serverNoResponse, self.localizedDescription)
//            }
            return .networkNotConnected
        } else {
            if self.code == 500 {
                return .server(ErrorCode.serverInternalError, self.localizedDescription, nil)
            } else if self.code == 401 {
                return .userLoginExpired
            }
        }
        return .server(ErrorCode.nserror, self.localizedDescription, nil)
    }
}

@available(iOS 12.0, *)
extension ASWebAuthenticationSessionError: HiErrorCompatible {
    public var hiError: HiError {
        switch self.code {
        case .canceledLogin:
            return .none
        default:
            return .app(ErrorCode.asError, self.localizedDescription, nil)
        }
    }
}

extension SFAuthenticationError: HiErrorCompatible {
    public var hiError: HiError {
        switch self.code {
        case .canceledLogin:
            return .none
        default:
            return .app(ErrorCode.skerror, self.localizedDescription, nil)
        }
    }
}

extension SKError: HiErrorCompatible {
    public var hiError: HiError {
        switch self.code {
        case .paymentCancelled:
            return .none
        default:
            return .app(ErrorCode.skerror, self.localizedDescription, nil)
        }
    }
}

extension RxError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .unknown: return .unknown
        case .timeout: return .timeout
        default: return .app(ErrorCode.rxerror, self.localizedDescription, nil)
        }
    }
}

extension AFError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case .explicitlyCancelled:
            return .timeout
        case let .sessionTaskFailed(error):
            return error.asHiError
        default:
            return .server(ErrorCode.aferror, self.localizedDescription, nil)
        }
    }
}

extension MoyaError: HiErrorCompatible {
    public var hiError: HiError {
        switch self {
        case let .underlying(error, _):
            return error.asHiError
        case let .statusCode(response):
            if response.statusCode == 401 {
                return .userNotLoginedIn
            }
            if response.statusCode == 403 {
                return .userLoginExpired
            }
            if let json = try? response.data.jsonObject() as? [String: Any],
               let message = json.string(for: Parameter.message), message.count != 0 {
                return .server(ErrorCode.moyaError, message, nil)
            }
            return .server(ErrorCode.moyaError, response.data.string(encoding: .utf8), nil)
        case .jsonMapping:
            return .server(ErrorCode.moyaError, self.localizedDescription, nil)
        default:
            return .server(ErrorCode.moyaError, self.localizedDescription, nil)
        }
    }
}

