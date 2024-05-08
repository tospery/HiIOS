//
//  UIView+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import RxTheme
import SwifterSwift

public extension Reactive where Base: UIView {
    
    var setNeedsLayout: Binder<Void> {
        return Binder(self.base) { view, _ in
            view.setNeedsLayout()
            view.layoutIfNeeded()
        }
    }
    
    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.layerBorderColor = color
        }
    }
    
    var qmui_borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            // YJX_TODO
            // view.qmui_borderColor = color
        }
    }
    
}

public extension ThemeProxy where Base: UIView {

    var borderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            base.layer.borderColor = newValue.value?.cgColor
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.borderColor)
            hold(disposable, for: "borderColor")
        }
    }

    var qmui_borderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            // YJX_TODO
            // base.qmui_borderColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.qmui_borderColor)
            hold(disposable, for: "qmui_borderColor")
        }
    }
    
}
