//
//  Router+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import SwiftEntryKit
import RswiftResources
import HiIOS

extension Router.Host {
    static var trending: Router.Host { "trending" }
    static var event: Router.Host { "event" }
    static var favorite: Router.Host { "favorite" }
    static var about: Router.Host { "about" }
    static var repo: Router.Host { "repo" }
    static var test: Router.Host { "test" }
}

extension Router.Path {
    static var options: Router.Path { "options" }
    static var branches: Router.Path { "branches" }
}

extension Router: RouterCompatible {
    
    public func isLogined() -> Bool {
        User.current?.isValid ?? false
    }
    
    public func isLegalHost(host: Host) -> Bool {
        true
    }
    
    public func allowedPaths(host: Host) -> [Path] {
        switch host {
        case .popup: return [
            .branches
        ]
        default: return []
        }
    }
    
    public func needLogin(host: Router.Host, path: Router.Path?) -> Bool {
        false
    }
    
    public func customLogin(
        _ provider: HiIOS.ProviderType,
        _ navigator: NavigatorProtocol,
        _ url: URLConvertible,
        _ values: [String: Any],
        _ context: Any?
    ) -> Bool {
        guard let top = UIViewController.topMost else { return false }
        if top.className.contains("LoginViewController") ||
            top.className.contains("TXSSOLoginViewController") {
            return false
        }
        var parameters = self.parameters(url, values, context) ?? [:]
        parameters[Parameter.transparetNavBar] = true
        let reactor = LoginViewReactor(provider, parameters)
        let controller = LoginViewController(navigator, reactor)
        let navigation = NavigationController(rootViewController: controller)
        top.present(navigation, animated: true)
        return true
    }

}
