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
            let result = base.jump(url, context: ctx, wrap: wrap, fromNav: fromNav, fromVC: fromVC, animated: animated, completion: completion)
            var success = false
            if let rt = result as? Bool {
                success = rt
            }
            if result is UIViewController {
                success = true
            }
            if !success {
                observer.onError(HiError.navigation)
            }
            return Disposables.create { }
        }
    }

}
