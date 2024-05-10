//
//  UITabBar+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import SwifterSwift
import RxTheme

public extension ThemeProxy where Base: UITabBar {

    /// (set only) bind a stream to barTintColor
    var unselectedItemTintColor: ThemeAttribute<UIColor?> {
        get { fatalError("set only") }
        set {
            base.unselectedItemTintColor = newValue.value
            let disposable = newValue.stream
                .take(until: base.rx.deallocating)
                .observe(on: MainScheduler.instance)
                .bind(to: base.rx.unselectedItemTintColor)
            hold(disposable, for: "unselectedItemTintColor")
        }
    }

}

//extension Reactive where Base: UITabBar {
//
//    @available(iOS 10.0, *)
//    public var unselectedItemTintColor: Binder<UIColor?> {
//        return Binder(self.base) { view, attr in
//            view.unselectedItemTintColor = attr
//        }
//    }
//
////    public var imageTintColor: Binder<UIColor?> {
////        return Binder(self.base) { view, attr in
////            if let items = view.items {
////                for item in items {
////                    item.image = item.image?.hi_image(withTintColor: attr)?.original
////                }
////            }
////        }
////    }
////
////    public var selectedImageTintColor: Binder<UIColor?> {
////        return Binder(self.base) { view, attr in
////            if let items = view.items {
////                for item in items {
////                    item.selectedImage = item.selectedImage?.hi_image(withTintColor: attr)?.original
////                }
////            }
////        }
////    }
//
//}
