//
//  MyRouter+Web.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import HiIOS
import URLNavigator

extension Router {
    
    enum Web: String {
        case agreement      = "html/userduty.htm"

        var urlString: String {
            switch self {
            case .agreement:
                return "\(UIApplication.shared.baseWebUrl)/\(self.rawValue)".url!
                    .appendingQueryParameters(envParameters.toStringString)
                    .absoluteString
            }
        }
    }
    
    public func webToNative(
        _ provider: HiIOS.ProviderType,
        _ navigator: NavigatorProtocol,
        _ url: URLConvertible,
        _ context: Any?
    ) -> Bool {
        guard let url = url.urlValue else { return false }
        var paths = url.pathComponents
        paths.removeAll("/")
        if paths.count == 0 {
            return navigator.forward(
                "\(UIApplication.shared.urlScheme)://\(Router.Host.user)/\(url.host ?? "")"
            )
        } else if paths.count == 1 {
            return navigator.forward(
                "\(UIApplication.shared.urlScheme)://\(Router.Host.repo)/\(url.host ?? "")/\(paths.first!)"
            )
        }
        return false
    }
    
    public func webViewController(
        _ provider: HiIOS.ProviderType,
        _ navigator: NavigatorProtocol,
        _ paramters: [String: Any]
    ) -> UIViewController? {
        WebViewController(navigator, WebViewReactor(provider, paramters))
    }
    
    public func web(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        
    }
    
}
