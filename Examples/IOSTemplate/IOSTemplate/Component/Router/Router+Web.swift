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
