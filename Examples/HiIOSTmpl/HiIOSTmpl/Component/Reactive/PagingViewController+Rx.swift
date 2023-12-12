//
//  PagingViewController+Rx.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxCocoa
import RxSwift
import RxTheme
import Parchment

public extension Reactive where Base: PagingViewController {

    var textColor: Binder<UIColor> {
        return Binder(self.base) { paging, color in
            paging.textColor = color
        }
    }
    
    var selectedTextColor: Binder<UIColor> {
        return Binder(self.base) { paging, color in
            paging.selectedTextColor = color
        }
    }
    
    var indicatorColor: Binder<UIColor> {
        return Binder(self.base) { paging, color in
            paging.indicatorColor = color
        }
    }

}

public extension ThemeProxy where Base: PagingViewController {

    var textColor: ThemeAttribute<UIColor> {
        get { fatalError("set only") }
        set {
            base.textColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.textColor)
            hold(disposable, for: "textColor")
        }
    }
    
    var selectedTextColor: ThemeAttribute<UIColor> {
        get { fatalError("set only") }
        set {
            base.selectedTextColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.selectedTextColor)
            hold(disposable, for: "selectedTextColor")
        }
    }
    
    var indicatorColor: ThemeAttribute<UIColor> {
        get { fatalError("set only") }
        set {
            base.indicatorColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.indicatorColor)
            hold(disposable, for: "indicatorColor")
        }
    }

}
