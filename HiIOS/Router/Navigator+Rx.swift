//
//  Navigator+Rx.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator_Hi
import SwifterSwift

extension Navigator: ReactiveCompatible { }
public extension Reactive where Base: Navigator {
    
    // MARK: - Public
    func jump(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        .create { [weak base] observer -> Disposable in
            guard let base = base else { return Disposables.create { } }
            var ctx = [String: Any].init()
            if let context = context as? [String: Any] {
                ctx = context
            } else {
                ctx[Parameter.routerContext] = context
            }
            ctx[Parameter.routerObserver] = observer
            guard base.jump(
                url,
                context: ctx,
                wrap: wrap,
                fromNav: fromNav,
                fromVC: fromVC,
                animated: animated,
                completion: completion
            ) else {
                observer.onError(HiError.navigation)
                return Disposables.create { }
            }
            return Disposables.create { }
        }
    }
    
    // MARK: - Internal
    internal func push(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Observable<UIViewController> {
        jump(url, context: (
            self.convert(context: context) + [
                Parameter.jumpType: JumpType.forward.rawValue,
                Parameter.forwardType: ForwardType.push.rawValue
            ]
        ), fromNav: from, animated: animated)
            .map { $0 as! UIViewController }
    }
    
    internal func open(
        _ url: URLConvertible,
        context: Any? = nil
    ) -> Observable<Any> {
        jump(url, context: (
            self.convert(context: context) + [
                Parameter.jumpType: JumpType.forward.rawValue,
                Parameter.forwardType: ForwardType.open.rawValue
            ]
        ))
    }

    internal func scene(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        jump(url, context: (
            self.convert(context: context) + [
                Parameter.jumpType: JumpType.forward.rawValue,
                Parameter.forwardType: ForwardType.open.rawValue,
                Parameter.openType: OpenType.scene.rawValue
            ]
        ), wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }

//    func back(
//        _ type: OldForwrdType? = nil,
//        animated: Bool = true,
//        result: Any? = nil
//    ) -> Observable<Any> {
//        forward(Router.shared.urlString(host: .back), context: [
//            Parameter.forwardType: type ?? .off,
//            Parameter.animated: animated,
//            Parameter.result: result
//        ])
//    }
    
    // MARK: - Private
    private func convert(context: Any? = nil) -> [String: Any] {
        var ctx = [String: Any].init()
        if let context = context as? [String: Any] {
            ctx = context
        } else {
            ctx[Parameter.routerContext] = context
        }
        return ctx
    }
    
}
