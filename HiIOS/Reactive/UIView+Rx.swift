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
    
    var layerBorderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.layerBorderColor = color
        }
    }
    
    var borderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            if let color = color {
                view.borderColors = [
                    .top: color,
                    .left: color,
                    .bottom: color,
                    .right: color
                ]
            } else {
                view.borderColors = nil
            }
        }
    }
    
}

public extension ThemeProxy where Base: UIView {

    var layerBorderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            base.layer.borderColor = newValue.value?.cgColor
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.layerBorderColor)
            hold(disposable, for: "layerBorderColor")
        }
    }

    var borderColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            if let color = newValue.value {
                base.borderColors = [
                    .top: color,
                    .left: color,
                    .bottom: color,
                    .right: color
                ]
            } else {
                base.borderColors = nil
            }
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.borderColor)
            hold(disposable, for: "borderColor")
        }
    }
    
}
