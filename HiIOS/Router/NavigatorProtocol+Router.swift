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

/// 前进的分类
public enum ForwardType: Int {
    /// 推进
    case push
    /// 打开
    case open
}

/// 后退的分类
public enum BackType: Int {
//    /// 自动
//    case auto
    /// 弹出（一个）
    case pop
    /// 弹出（所有）
    case off
    /// 关闭
    case close
}

/// 打开的分类
public enum OpenType: Int {
    /// 场景
    case scene
    /// 弹窗
    case popup
    /// 表单框（可操作的）
    case sheet
    /// 提示框（可选择的）
    case alert
    /// 消息框（自动关闭）
    case toast
}

public enum OldForwrdType: Int {
    // to
    case push
    case present
    case open
    // back
    case auto
    case to
    case off
    case all
    case dismiss
}

//public enum BackType {
//    case pop
//    case popAll
//    case popTo(UIViewController)
//    case dismiss
//}

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
        
        if self.checkScheme(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion) {
            return false
        }
        if self.checkLogin(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion) {
            return true
        }
        
        let jumpType = JumpType.init(
            rawValue: self.getType(url, context: context, key: Parameter.jumpType) ?? 0
        ) ?? .forward
        switch jumpType {
        case .forward:
            return self.forward(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
        case .back:
            return self.open(url, context: context)
        }
        return false
    }
    
    @discardableResult
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
    
    // MARK: back
    func back(type: BackType? = nil, animated: Bool = true, message: String? = nil) {
        self.jump(Router.shared.urlString(host: .back), context: [
            Parameter.backType: type,
            Parameter.animated: animated,
            Parameter.message: message
        ])
    }
    
    func rxBack(type: BackType? = nil, animated: Bool = true, message: String? = nil) -> Observable<Any> {
        (self as! Navigator).rx.jump(Router.shared.urlString(host: .back), context: [
            Parameter.backType: type,
            Parameter.animated: animated,
            Parameter.message: message
        ])
    }
//    @discardableResult
//    private func back(
//        _ url: URLConvertible,
//        context: Any? = nil,
//        wrap: UINavigationController.Type? = nil,
//        fromNav: UINavigationControllerType? = nil,
//        fromVC: UIViewControllerType? = nil,
//        animated: Bool = true,
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        return false
//    }
    
//    @discardableResult
//    func scene(
//        _ url: URLConvertible,
//        context: Any? = nil,
//        wrap: UINavigationController.Type? = nil,
//        fromNav: UINavigationControllerType? = nil,
//        fromVC: UIViewControllerType? = nil,
//        animated: Bool = true,
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        return false
//    }
//    
//    @discardableResult
//    func popup(
//        _ url: URLConvertible,
//        context: Any? = nil,
//        wrap: UINavigationController.Type? = nil,
//        fromNav: UINavigationControllerType? = nil,
//        fromVC: UIViewControllerType? = nil,
//        animated: Bool = true,
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        return false
//    }
//    
//    @discardableResult
//    func sheet(
//        _ url: URLConvertible,
//        context: Any? = nil,
//        wrap: UINavigationController.Type? = nil,
//        fromNav: UINavigationControllerType? = nil,
//        fromVC: UIViewControllerType? = nil,
//        animated: Bool = true,
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        return false
//    }
//    
//    @discardableResult
//    func alert(
//        _ url: URLConvertible,
//        context: Any? = nil,
//        wrap: UINavigationController.Type? = nil,
//        fromNav: UINavigationControllerType? = nil,
//        fromVC: UIViewControllerType? = nil,
//        animated: Bool = true,
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        return false
//    }
//    
//    @discardableResult
//    func toast(
//        _ url: URLConvertible,
//        context: Any? = nil,
//        wrap: UINavigationController.Type? = nil,
//        fromNav: UINavigationControllerType? = nil,
//        fromVC: UIViewControllerType? = nil,
//        animated: Bool = true,
//        completion: (() -> Void)? = nil
//    ) -> Bool {
//        return false
//    }
    
    // MARK: push/open
    @discardableResult
    func forwardPush(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Bool {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.push.rawValue
        return self.jump(url, context: ctx, fromNav: from, animated: animated)
    }
    
    @discardableResult
    func forwardOpen(
        _ url: URLConvertible,
        context: Any? = nil
    ) -> Bool {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        return self.jump(url, context: ctx)
    }
    
    @discardableResult
    func scene(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        var ctx = self.convert(context: context)
        ctx[Parameter.jumpType] = JumpType.forward.rawValue
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        ctx[Parameter.openType] = OpenType.scene.rawValue
        return self.jump(url, context: ctx, wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }
    
//    func back(animated: Bool = true, type: OldForwrdType? = nil, _ completion: (() -> Void)? = nil) {
//        guard let top = UIViewController.topMost else { return }
//        guard let type = type else {
//            if top.navigationController?.viewControllers.count ?? 0 > 1 {
//                top.navigationController?.popViewController(animated: animated, completion)
//            } else {
//                top.dismiss(animated: animated, completion: completion)
//            }
//            return
//        }
//        switch type {
//        case .pop:
//            top.navigationController?.popViewController(animated: animated, completion)
//        case .dismiss:
//            top.dismiss(animated: animated, completion: completion)
//        default:
//            break
//        }
//    }
//    func back(
//        _ type: OldForwrdType? = nil,
//        animated: Bool = true,
//        result: Any? = nil,
//        completion: (() -> Void)? = nil
//    ) {
////        (self as! Navigator).rx.open(
////            Router.shared.urlString(
////                host: .alert,
////                parameters: [
////                    Parameter.title: title,
////                    Parameter.message: message
////                ]),
////            context: [
////                Parameter.actions: actions
////            ]
////        )
//        (self as! Navigator).rx.open(Router.shared.urlString(host: .back), context: [
//        ])
//    }
    
//    func rxBack(
//        _ type: OldForwrdType? = nil,
//        animated: Bool = true,
//        result: Any? = nil
//    ) {
//        (self as! Navigator).rx.open(Router.shared.urlString(host: .back), context: [
//            Parameter.forwardType: type ?? .off,
//            Parameter.animated: animated,
//            Parameter.result:
//        ])
//    }
    
    // MARK: - Toast
    func toastMessage(_ message: String, _ style: HiToastStyle = .success) {
        guard !message.isEmpty else { return }
        self.open(Router.shared.urlString(host: .toast, parameters: [
            Parameter.style: style.rawValue.string,
            Parameter.message: message
        ]))
    }
    
    func showToastActivity() {
        self.open(Router.shared.urlString(host: .toast, parameters: [
            Parameter.active: true.string
        ]))
    }
    
    func hideToastActivity() {
        self.open(Router.shared.urlString(host: .toast, parameters: [
            Parameter.active: false.string
        ]))
    }
    
    // MARK: - Alert
    func alert(_ title: String, _ message: String, _ actions: [AlertActionType]) {
        self.open(
            Router.shared.urlString(
                host: .alert,
                parameters: [
                    Parameter.title: title,
                    Parameter.message: message
                ]),
            context: [
                Parameter.actions: actions
            ]
        )
    }

    func rxAlert(_ title: String, _ message: String, _ actions: [AlertActionType]) -> Observable<Any> {
        (self as! Navigator).rx.open(
            Router.shared.urlString(
                host: .alert,
                parameters: [
                    Parameter.title: title,
                    Parameter.message: message
                ]),
            context: [
                Parameter.actions: actions
            ]
        )
    }
    
    // MARK: - Sheet
    func sheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) {
        var parameters = [String: String].init()
        parameters[Parameter.title] = title
        parameters[Parameter.message] = message
        self.open(
            Router.shared.urlString(
                host: .sheet,
                parameters: parameters
            ),
            context: [
                Parameter.actions: actions
            ]
        )
    }

    func rxSheet(_ title: String?, _ message: String?, _ actions: [AlertActionType]) -> Observable<Any> {
        var parameters = [String: String].init()
        parameters[Parameter.title] = title
        parameters[Parameter.message] = message
        return (self as! Navigator).rx.open(
            Router.shared.urlString(
                host: .sheet,
                parameters: parameters
            ),
            context: [
                Parameter.actions: actions
            ]
        )
    }
    
    // MARK: - Popup
    func popup(_ path: Router.Path, context: Any? = nil) {
        self.open(
            Router.shared.urlString(host: .popup, path: path),
            context: context
        )
    }
    
    func rxPopup(_ path: Router.Path, context: Any? = nil) -> Observable<Any> {
        (self as! Navigator).rx.open(
            Router.shared.urlString(host: .popup, path: path),
            context: context
        )
    }
    
    // MARK: - Login
    func login() {
        self.open(Router.shared.urlString(host: .login))
    }
    
    func rxLogin() -> Observable<Any> {
        (self as! Navigator).rx.open(Router.shared.urlString(host: .login))
    }
    
    
//
//    func sheet(_ path: Router.Path, context: Any? = nil) {
//        self.navigator.open(Router.urlString(host: .sheet, path: path), context: context)
//    }
//
//    func rxSheet(_ path: Router.Path, context: Any? = nil) -> Observable<Any> {
//        (self.navigator as! Navigator).rx.open(Router.urlString(host: .sheet, path: path), context: context)
//    }
    
    func convert(context: Any? = nil) -> [String: Any] {
        var ctx = [String: Any].init()
        if let context = context as? [String: Any] {
            ctx = context
        } else {
            ctx[Parameter.routerContext] = context
        }
        return ctx
    }
    
    // MARK: - Internal
    
    // MARK: - Private
    private func checkScheme(
        _ url: URLConvertible,
        context: Any?,
        wrap: UINavigationController.Type?,
        fromNav: UINavigationControllerType?,
        fromVC: UIViewControllerType?,
        animated: Bool,
        completion: (() -> Void)?
    ) -> Bool {
        guard let url = url.urlValue else { return false }
        guard let scheme = url.scheme else { return false }
        if scheme != UIApplication.shared.urlScheme && scheme != "http" && scheme != "https" {
            logger.print("其他scheme的url: \(url)", module: .hiIOS)
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return true
            }
        }
        return false
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
        guard let host = url.host, host != .back else { return false }
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
            (self as! Navigator).rx.open(
                router.urlString(host: .login)
            ).subscribe(onNext: { result in
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
    
    private func getType(_ url: URLConvertible, context: Any?, key: String) -> Int {
        var parameters: [String: Any] = url.queryParameters ?? [:]
        parameters += context as? [String: Any] ?? [:]
        return parameters.int(for: key) ?? 0
    }
    
    /// 用户参数优先级高于函数参数/
    private func getAnimated(_ url: URLConvertible, context: Any?, animated: Bool) -> Bool {
        var parameters: [String: Any] = url.queryParameters ?? [:]
        parameters += context as? [String: Any] ?? [:]
        return parameters.bool(for: Parameter.animated) ?? animated
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
        let forwardType = ForwardType.init(
            rawValue: self.getType(url, context: context, key: Parameter.forwardType) ?? 0
        ) ?? .push
        switch forwardType {
        case .push:
            let animated = self.getAnimated(url, context: context, animated: animated)
            return self.push(url, context: context, from: fromNav, animated: animated) != nil
        case .open:
            return self.open(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
        }
        return false
    }
    
    @discardableResult
    private func open(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        let openType = OpenType.init(
            rawValue: self.getType(url, context: context, key: Parameter.openType) ?? 0
        ) ?? .scene
        switch openType {
        case .scene:
            let animated = self.getAnimated(url, context: context, animated: animated)
            return self.present(url, context: context, wrap: wrap ?? NavigationController.self, from: fromVC, animated: animated, completion: completion) != nil
        default:
            return self.open(url, context: context)
        }
    }
    
}
