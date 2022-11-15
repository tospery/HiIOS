//
//  UIBarAppearance+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxCocoa
import RxSwift
import RxTheme

@available(iOS 13.0, *)
public extension ThemeProxy where Base: UIBarAppearance {

    var backgroundColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            base.backgroundColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.backgroundColor)
            hold(disposable, for: "backgroundColor")
        }
    }

}
