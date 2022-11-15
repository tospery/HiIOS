//
//  UITextView+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: UITextView {
    
    var placeholderColor: Binder<UIColor?> {
        return Binder(self.base) { view, color in
            view.placeholderColor = color
        }
    }
    
}
