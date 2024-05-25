//
//  UITextView+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import HiCore

import HiTheme
import HiNav

public extension Reactive where Base: UITextView {
    
    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.placeholderColor = color
        }
    }
    
}

public extension ThemeProxy where Base: UITextView {

    var placeholderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            base.placeholderColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.placeholderColor)
            hold(disposable, for: "placeHolderColor")
        }
    }

}
