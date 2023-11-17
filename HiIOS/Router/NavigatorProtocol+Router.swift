//
//  NavigatorProtocol+Router.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator
import SwifterSwift

var navigateBag = DisposeBag()

public enum ForwardType: Int {
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

    // MARK: - Forward（支持自动跳转登录页功能）
    @discardableResult
    func forward(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        guard let url = url.urlValue else { return false }
        guard let host = url.host else { return false }
        // 检测登录要求
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
                logger.print("自动跳转登录页(数据): \(result)")
            }, onError: { error in
                logger.print("自动跳转登录页(错误): \(error)")
            }, onCompleted: {
                logger.print("自动跳转登录页(完成)")
                var hasLogined = false
                if let compatible = router as? RouterCompatible {
                    hasLogined = compatible.isLogined()
                }
                if hasLogined {
                    self.forward(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
                }
            }).disposed(by: navigateBag)
            return true
        }
        
        // context中的参数的优先级高于查询参数
        var parameters: [String: Any] = url.queryParameters ?? [:]
        parameters += context as? [String: Any] ?? [:]
        let forwardValue = parameters.int(
            for: Parameter.forwardType
        ) ?? (host == .back ? ForwardType.auto.rawValue : ForwardType.push.rawValue)
        let forwardType = ForwardType.init(
            rawValue: forwardValue
        ) ?? (host == .back ? ForwardType.auto : ForwardType.push)
        
        // 用户参数优先级高于函数参数
        let animated = parameters.bool(for: Parameter.animated) ?? animated
        
        // 打印路由地址
        logger.print("导航\(url.absoluteString)\n\(parameters)", module: .hiIOS)
        
        switch forwardType {
        case .push:
            if self.push(url, context: context, from: fromNav, animated: animated) != nil {
                return true
            }
        case .present:
            if self.present(url, context: context, wrap: wrap ?? NavigationController.self, from: fromVC, animated: animated, completion: completion) != nil {
                return true
            }
        default:
            break
        }
        return self.open(url, context: context)
    }
    
    @discardableResult
    func rxForward(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        (self as! Navigator).rx.forward(url, context: context, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
    }
    
    // MARK: - Push
    @discardableResult
    func fPush(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Bool {
        self.forward(url, context: context, fromNav: from, animated: animated)
    }
    
    // MARK: - Present
    @discardableResult
    func fPresent(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Bool {
        var ctx = self.convert(context: context)
        ctx[Parameter.forwardType] = ForwardType.present.rawValue
        return self.forward(url, context: ctx, wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }
    
    // MARK: - Open
    @discardableResult
    func fOpen(
        _ url: URLConvertible,
        context: Any? = nil
    ) -> Bool {
        var ctx = self.convert(context: context)
        ctx[Parameter.forwardType] = ForwardType.open.rawValue
        return self.forward(url, context: ctx)
    }
    
    // MARK: - Back
    func back(type: ForwardType? = nil, animated: Bool = true, message: String? = nil) {
        self.forward(Router.shared.urlString(host: .back), context: [
            Parameter.forwardType: type,
            Parameter.animated: animated,
            Parameter.message: message
        ])
    }
    
    func rxBack(type: ForwardType? = nil, animated: Bool = true, message: String? = nil) -> Observable<Any> {
        (self as! Navigator).rx.forward(Router.shared.urlString(host: .back), context: [
            Parameter.forwardType: type,
            Parameter.animated: animated,
            Parameter.message: message
        ])
    }
    
//    func back(animated: Bool = true, type: ForwardType? = nil, _ completion: (() -> Void)? = nil) {
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
//        _ type: ForwardType? = nil,
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
//        _ type: ForwardType? = nil,
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
    
}
