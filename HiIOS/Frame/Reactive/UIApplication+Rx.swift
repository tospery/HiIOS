//
//  UIApplication+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIApplication {

    var statusBarStyle: Binder<UIStatusBarStyle> {
        return Binder(self.base) { _, attr in
            statusBarService.accept(attr)
        }
    }

}
