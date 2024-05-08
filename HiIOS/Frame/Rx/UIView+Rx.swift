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
    
    var sideBorderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            if let color = color {
                view.sideColors = [
                    .top: color,
                    .left: color,
                    .bottom: color,
                    .right: color
                ]
            } else {
                view.sideColors = nil
            }
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

    var sideBorderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            if let color = newValue.value {
                base.sideColors = [
                    .top: color,
                    .left: color,
                    .bottom: color,
                    .right: color
                ]
            } else {
                base.sideColors = nil
            }
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.sideBorderColor)
            hold(disposable, for: "sideBorderColor")
        }
    }
    
}
