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
    
    func forward(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        fromNav: UINavigationControllerType? = nil,
        fromVC: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        return .create { [weak base] observer -> Disposable in
            guard let base = base else { return Disposables.create { } }
            var ctx = [String: Any].init()
            if let context = context as? [String: Any] {
                ctx = context
            } else {
                ctx[Parameter.routerContext] = context
            }
            ctx[Parameter.routerObserver] = observer
            guard base.forward(
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
    
    func push(
        _ url: URLConvertible,
        context: Any? = nil,
        from: UINavigationControllerType? = nil,
        animated: Bool = true
    ) -> Observable<UIViewController> {
        forward(url, context: (
            self.convert(context: context) + [
                Parameter.forwardType: ForwardType.push.rawValue
            ]
        ), fromNav: from, animated: animated)
            .map { $0 as! UIViewController }
    }

    func present(
        _ url: URLConvertible,
        context: Any? = nil,
        wrap: UINavigationController.Type? = nil,
        from: UIViewControllerType? = nil,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) -> Observable<Any> {
        forward(url, context: (
            self.convert(context: context) + [
                Parameter.forwardType: ForwardType.present.rawValue
            ]
        ), wrap: wrap, fromVC: from, animated: animated, completion: completion)
    }
    
    func open(
        _ url: URLConvertible,
        context: Any? = nil
    ) -> Observable<Any> {
        forward(url, context: (
            self.convert(context: context) + [
                Parameter.forwardType: ForwardType.open.rawValue
            ]
        ))
    }

//    func back(
//        _ type: ForwardType? = nil,
//        animated: Bool = true,
//        result: Any? = nil
//    ) -> Observable<Any> {
//        forward(Router.shared.urlString(host: .back), context: [
//            Parameter.forwardType: type ?? .off,
//            Parameter.animated: animated,
//            Parameter.result: result
//        ])
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
