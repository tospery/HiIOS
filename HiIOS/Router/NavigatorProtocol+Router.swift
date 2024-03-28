//
//  NavigatorProtocol+Router.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator_Hi
import SwifterSwift

var navigateBag = DisposeBag()

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

public extension NavigatorProtocol {

    // MARK: - Public
    // MARK: jump
    @discardableResult
    func jump(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        guard let url = url.urlValue else { return false }
        var parameters: [String: Any] = url.queryParameters ?? [:]
        // context中的参数的优先级高于查询参数
        parameters += context as? [String: Any] ?? [:]
        // 打印路由地址
        logger.print("导航地址->\(url.absoluteString)\n\(parameters)", module: .hiIOS)
        
        let myURL = self.checkScheme(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
        if myURL == nil {
            return false
        }
        
        if self.checkLogin(myURL!, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion) {
            return true
        }
        
        var type: JumpType?
        if url.host == .back {
            type = .back
        } else {
            if let value = self.getType(myURL!, context: context, key: Parameter.jumpType),
               let jump = JumpType.init(rawValue: value) {
                type = jump
            } else {
                type = .forward
            }
        }
        switch type! {
        case .forward:
            return self.forward(myURL!, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
        case .back:
            return self.open(myURL!, context: context)
        }
    }
    
    func rxJump(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        (self as! Navigator).rx.jump(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
    }
    
    // MARK: push
    @discardableResult
    func pushX(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Bool {
        self.jump(url, context: self.contextForPush(context: context), fromNav: from, animated: animated)
    }
    
    func rxPushX(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Observable<Any> {
        self.rxJump(url, context: self.contextForPush(context: context), fromNav: from, animated: animated)
    }
    
    // MARK: present
    @discardableResult
    func presentX(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        self.jump(url, context: self.contextForPresent(context: context), wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }
    
    func rxPresentX(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        self.rxJump(url, context: self.contextForPresent(context: context), wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }
    
    // MARK: toast
    func toastMessage(_ message: String, _ style: HiToastStyle = .success) {
        guard !message.isEmpty else { return }
        var parameters = [String: String].init()
        parameters[Parameter.message] = message
        parameters[Parameter.style] = style.rawValue.string
        var ctx = self.convert()
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.toast.rawValue
        self.jump(Router.shared.urlString(host: .toast, parameters: parameters), context: ctx)
    }
    
    func showToastActivity(active: Bool = true) {
        var parameters = [String: String].init()
        parameters[Parameter.active] = active.string
        var ctx = self.convert()
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.toast.rawValue
        self.jump(Router.shared.urlString(host: .toast, parameters: parameters), context: ctx)
    }
    
    func hideToastActivity() {
        self.showToastActivity(active: false)
    }
    
    // MARK: - alert
    @discardableResult
    func alert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> Bool {
        let info = self.infoForAlert(title, message, actions)
        return self.jump(Router.shared.urlString(host: .alert, parameters: info.0), context: info.1)
    }

    func rxAlert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> Observable<Any> {
        let info = self.infoForAlert(title, message, actions)
        return self.rxJump(Router.shared.urlString(host: .alert, parameters: info.0), context: info.1)
    }
    
    // MARK: sheet
    @discardableResult
    func sheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> Bool {
        let info = self.infoForSheet(title, message, actions)
        return self.jump(Router.shared.urlString(host: .sheet, parameters: info.0), context: info.1)
    }

    func rxSheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> Observable<Any> {
        let info = self.infoForSheet(title, message, actions)
        return self.rxJump(Router.shared.urlString(host: .sheet, parameters: info.0), context: info.1)
    }
    
    // MARK: popup
    @discardableResult
    func popup(_ path: Router.Path, context: Any? = nil) -> Bool {
        self.jump(Router.shared.urlString(host: .popup, path: path), context: self.contextForPopup(context: context))
    }
    
    func rxPopup(_ path: Router.Path, context: Any? = nil) -> Observable<Any> {
        self.rxJump(Router.shared.urlString(host: .popup, path: path), context: self.contextForPopup(context: context))
    }
    
    // MARK: login
    func login() {
        self.jump(Router.shared.urlString(host: .login), context: self.contextForLogin())
    }
    
    func rxLogin() -> Observable<Any> {
        self.rxJump(Router.shared.urlString(host: .login), context: self.contextForLogin())
    }

    // MARK: back
    func back(type: BackType? = nil, animated: Bool = true, message: String? = nil) {
        self.jump(Router.shared.urlString(host: .back), context: self.contextForBack(type: type, animated: animated, message: message))
    }
    
    func rxBack(type: BackType? = nil, animated: Bool = true, message: String? = nil) -> Observable<Any> {
        self.rxJump(Router.shared.urlString(host: .back), context: self.contextForBack(type: type, animated: animated, message: message))
    }
    
    // MARK: - Private
    private func checkScheme(
        _ url: URLConvertible,
        context: Any?,
        wrap: UINavigationController.Type?,
        fromNav: UINavigationControllerType?,
        fromVC: UIViewControllerType?,
        animated: Bool,
        completion: (() -> Void)?
    ) -> URLConvertible? {
        guard var myURL = url.urlValue else { return nil }
        if myURL.scheme?.isEmpty ?? true {
            myURL = "https://\(myURL.absoluteString)".url ?? myURL
        }
        guard let scheme = myURL.scheme else { return nil }
        if scheme != UIApplication.shared.urlScheme && scheme != "http" && scheme != "https" {
            logger.print("第三方url: \(myURL)", module: .hiIOS)
            if UIApplication.shared.canOpenURL(myURL) {
                UIApplication.shared.open(myURL, options: [:], completionHandler: nil)
                return nil
            }
            logger.print("无法打开该url: \(myURL)", module: .hiIOS)
            return nil
        }
        return myURL
    }
    
    private func checkLogin(
        _ url: URLConvertible,
        context: Any?,
        wrap: UINavigationController.Type?,
        fromNav: UINavigationControllerType?,
        fromVC: UIViewControllerType?,
        animated: Bool,
        completion: (() -> Void)?
    ) -> Bool {
        guard let url = url.urlValue else { return false }
        guard let host = url.host, host != .back, !OpenType.allHosts.contains(host) else { return false }
        var needLogin = false
        var isLogined = true
        let router = Router.shared
        if let compatible = router as? RouterCompatible {
            isLogined = compatible.isLogined()
            if compatible.needLogin(host: host, path: url.path) {
                needLogin = true
            }
        } else {
            if host == .user {
                needLogin = true
            }
        }
        if needLogin && !isLogined {
            self.rxLogin()
                .subscribe(onNext: { result in
                    logger.print("自动跳转登录页(数据): \(result)", module: .hiIOS)
                }, onError: { error in
                    logger.print("自动跳转登录页(错误): \(error)", module: .hiIOS)
                }, onCompleted: {
                    logger.print("自动跳转登录页(完成)", module: .hiIOS)
                    var hasLogined = false
                    if let compatible = router as? RouterCompatible {
                        hasLogined = compatible.isLogined()
                    }
                    if hasLogined {
                        self.jump(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
                    }
                }).disposed(by: navigateBag)
            return true
        }
        return false
    }
    
    private func getType(_ url: URLConvertible, context: Any?, key: String) -> Int? {
        var parameters: [String: Any] = url.queryParameters ?? [:]
        parameters += context as? [String: Any] ?? [:]
        return parameters.int(for: key)
    }
    
    /// 用户参数优先级高于函数参数/
    private func getAnimated(_ url: URLConvertible, context: Any?, animated: Bool) -> Bool {
        var parameters: [String: Any] = url.queryParameters ?? [:]
        parameters += context as? [String: Any] ?? [:]
        return parameters.bool(for: Parameter.animated) ?? animated
    }
    
    private func convert(context: Any? = nil) -> [String: Any] {
        var ctx = [String: Any].init()
        if let context = context as? [String: Any] {
            ctx = context
        } else {
            ctx[Parameter.routerContext] = context
        }
        return ctx
    }
    
    private func contextForPush(context: Any?) -> Any {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.push.rawValue
        return ctx
    }
    
    private func contextForPresent(context: Any?) -> Any {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.present.rawValue
        return ctx
    }
    
    private func contextForPopup(context: Any?) -> Any {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.popup.rawValue
        return ctx
    }
    
    private func contextForLogin() -> Any {
        var ctx = self.convert()
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.login.rawValue
        return ctx
    }
    
    private func contextForBack(type: BackType?, animated: Bool, message: String?) -> Any {
        var ctx = self.convert(context: [
            Parameter.backType: type,
            Parameter.animated: animated,
            Parameter.message: message
        ])
        ctx[Parameter.jumpType] = JumpType.back.rawValue
        return ctx
    }
    
    private func infoForSheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> ([String: String], [String: Any]) {
        var parameters = [String: String].init()
        parameters[Parameter.title] = title
        parameters[Parameter.message] = message
        var context = self.convert(context: [
            Parameter.actions: actions
        ])
        context[Parameter.jumpType] = JumpType.forward.rawValue
        context[Parameter.forwardType] = ForwardType.open.rawValue
        context[Parameter.openType] = OpenType.sheet.rawValue
        return (parameters, context)
    }
    
    private func infoForAlert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> ([String: String], [String: Any]) {
        var parameters = [String: String].init()
        parameters[Parameter.title] = title
        parameters[Parameter.message] = message
        var context = self.convert(context: [
            Parameter.actions: actions
        ])
        context[Parameter.jumpType] = JumpType.forward.rawValue
        context[Parameter.forwardType] = ForwardType.open.rawValue
        context[Parameter.openType] = OpenType.alert.rawValue
        return (parameters, context)
    }
    
    @discardableResult
    private func forward(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        var type: ForwardType?
        if OpenType.allHosts.contains(url.urlValue?.host ?? "") {
            type = .open
        } else {
            if let value = self.getType(url, context: context, key: Parameter.forwardType),
               let forward = ForwardType.init(rawValue: value) {
                type = forward
            } else {
                type = .push
            }
        }
        switch type! {
        case .push:
            let animated = self.getAnimated(url, context: context, animated: animated)
            return self.push(url, context: context, from: fromNav, animated: animated) != nil
        case .present:
            let animated = self.getAnimated(url, context: context, animated: animated)
            return self.present(url, context: context, wrap: wrap ?? NavigationController.self, from: fromVC, animated: animated, completion: completion) != nil
        case .open:
            return self.open(url, context: context)
        }
    }

}
