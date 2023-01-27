//
//  Router.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator

public protocol RouterCompatible {
    
    func isLogined() -> Bool
    
    func isLegalHost(host: Router.Host) -> Bool
    func allowedPaths(host: Router.Host) -> [Router.Path]
    
    func needLogin(host: Router.Host, path: Router.Path?) -> Bool
    func customLogin(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> Bool
    
    func webToNative(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol, _ url: URLConvertible, _ context: Any?) -> Bool
    func webViewController(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol, _ paramters: [String: Any]) -> UIViewController?
    
    func web(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol)
    func page(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol)
    func dialog(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol)
    
}

final public class Router {

    public typealias Host = String
    public typealias Path = String
    
    public static var shared = Router()
    
    init() {
    }
    
    public func initialize(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        self.buildinMatch(provider, navigator)
        self.buildinWeb(provider, navigator)
        self.buildinBack(provider, navigator)
        self.buildinLogin(provider, navigator)
        if let compatible = self as? RouterCompatible {
            compatible.web(provider, navigator)
            compatible.page(provider, navigator)
            compatible.dialog(provider, navigator)
        }
    }
    
    func buildinMatch(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        (navigator as? Navigator)?.matcher.valueConverters["type"] = { [weak self] pathComponents, index in
            guard let `self` = self else { return nil }
            if let compatible = self as? RouterCompatible {
                let host = pathComponents[0]
                if compatible.isLegalHost(host: host) {
                    let path = pathComponents[index]
                    if compatible.allowedPaths(host: host).contains(path) {
                        return path
                    }
                }
            }
            return nil
        }
    }
    
    func buildinWeb(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        let webFactory: ViewControllerFactory = { [weak self] (url, values, context) in
            guard let `self` = self else { return nil }
            guard let url = url.urlValue else { return nil }
            let string = url.absoluteString
            var paramters = self.parameters(url, values, context) ?? [:]
            paramters[Parameter.url] = string
            if let title = url.queryValue(for: Parameter.title) {
                paramters[Parameter.title] = title
            }
            let force = paramters.bool(for: Parameter.routerForceWeb) ?? false
            if !force {
                // (1) 原生支持
                let base = UIApplication.shared.baseWebUrl + "/"
                if string.hasPrefix(base) {
                    let url = string.replacingOccurrences(of: base, with: UIApplication.shared.urlScheme + "://")
                    if navigator.forward(url, context: context) {
                        return nil
                    }
                    if let compatible = self as? RouterCompatible {
                        if compatible.webToNative(provider, navigator, url, context) {
                            return nil
                        }
                    }
                }
            }
            // (2) 网页跳转
            if let compatible = self as? RouterCompatible {
                return compatible.webViewController(provider, navigator, paramters)
            }
            return nil
        }
        navigator.register("http://<path:_>", webFactory)
        navigator.register("https://<path:_>", webFactory)
    }
    
    func buildinBack(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .back)) { url, values, context in
            guard let top = UIViewController.topMost else { return false }
            let parameters = self.parameters(url, values, context)
            if let message = parameters?.string(for: Parameter.message), message.isNotEmpty {
                navigator.toastMessage(message)
            }
            let result = parameters?[Parameter.result]
            let observer = parameters?[Parameter.routerObserver] as? AnyObserver<Any>
            let completion: (() -> Void) = {
                if result != nil {
                    observer?.onNext(result)
                }
                observer?.onCompleted()
            }
            let forward = parameters?.enum(for: Parameter.forwardType, type: ForwardType.self) ?? .auto
            let animated = parameters?.bool(for: Parameter.animated) ?? true
            switch forward {
            case .off:
                popOne(viewController: top, animated: animated, completion)
            case .all:
                popAll(viewController: top, animated: animated, completion)
            case .dismiss:
                HiIOS.dismiss(viewController: top, animated: animated, completion)
            default:
                if top.navigationController?.viewControllers.count ?? 0 > 1 {
                    popOne(viewController: top, animated: animated, completion)
                } else {
                    HiIOS.dismiss(viewController: top, animated: animated, completion)
                }
            }
            return true
        }
    }
    
    func buildinLogin(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .login)) { url, values, context in
            if let compatible = self as? RouterCompatible {
                return compatible.customLogin(provider, navigator, url, values, context)
            }
            return false
        }
    }
    
    public func parameters(_ url: URLConvertible, _ values: [String: Any], _ context: Any?) -> [String: Any]? {
        // 1. 基础参数
        var parameters: [String: Any] = url.queryParameters
        for (key, value) in values {
            parameters[key] = value
        }
        if let context = context {
            if let ctx = context as? [String: Any] {
                for (key, value) in ctx {
                    parameters[key] = value
                }
            } else {
                parameters[Parameter.routerContext] = context
            }
        }
        // 2. Host
        guard let host = url.urlValue?.host else { return nil }
        parameters[Parameter.routerHost] = host
        // 3. Path
        let path = url.urlValue?.path.removingPrefix("/").removingSuffix("/")
        parameters[Parameter.routerPath] = path?.isEmpty ?? true ? nil : path
        // 4. 标题
        parameters[Parameter.title] = parameters.string(for: Parameter.title)
//        var title: String? = nil
//        if let compatible = self as? RouterCompatible {
//            title = compatible.title(host: host, path: path)
//        }
//        parameters[Parameter.title] = parameters.string(for: Parameter.title) ?? title
        // 5. 刷新/加载
//        var shouldRefresh = false
//        var shouldLoadMore = false
//        if let compatible = self as? RouterCompatible {
//            shouldRefresh = compatible.shouldRefresh(host: host, path: path)
//            shouldLoadMore = compatible.shouldLoadMore(host: host, path: path)
//        }
//        parameters[Parameter.shouldRefresh] = parameters.bool(for: Parameter.shouldRefresh) ?? shouldRefresh
//        parameters[Parameter.shouldLoadMore] = parameters.bool(for: Parameter.shouldLoadMore) ?? shouldLoadMore
        parameters[Parameter.routerUrl] = url.urlStringValue
        
        return parameters
    }
    
    /// 注册的pattern
    /// 对于详情页，如app://user/detail采用<id>匹配模式
    /// 此时，需要注册两个patter，分别为app://user/42980和app://user
    /// 前者用于跳转到指定用户的详情页，后者用户跳转到当前登录用户的详情页
    public func urlPattern(host: Router.Host, path: Path? = nil, placeholder: String? = nil) -> String {
        var url = "\(UIApplication.shared.urlScheme)://\(host)"
        if let path = path {
            url += "/\(path)"
        }
        if let placeholder = placeholder {
            url += "/\(placeholder)"
        }
        return url
    }
    
    public func urlString(host: Router.Host, path: Path? = nil, parameters: [String: String]? = nil) -> String {
        var url = "\(UIApplication.shared.urlScheme)://\(host)".url!
        if let path = path {
            url.appendPathComponent(path)
        }
        if let parameters = parameters {
            url.appendQueryParameters(parameters)
        }
        return url.absoluteString
    }

}

extension Router.Host {
    public static var back: Router.Host { "back" }
    
    public static var toast: Router.Host { "toast" }
    public static var alert: Router.Host { "alert" }
    public static var sheet: Router.Host { "sheet" }
    public static var popup: Router.Host { "popup" }
    
    public static var dashboard: Router.Host { "dashboard" }
    public static var personal: Router.Host { "personal" }
    
    public static var user: Router.Host { "user" }
    public static var profile: Router.Host { "profile" }
    public static var login: Router.Host { "login" }
    public static var setting: Router.Host { "setting" }
    public static var about: Router.Host { "about" }
    public static var search: Router.Host { "search" }
}

extension Router.Path {
    public static var page: Router.Path { "page" }
    public static var list: Router.Path { "list" }
    public static var detail: Router.Path { "detail" }
    public static var history: Router.Path { "history" }
}

