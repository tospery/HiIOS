//
//  UISegmentedControl+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
    
extension Reactive where Base: UISegmentedControl {
    
    public func titleTextAttributes(for state: UIControl.State) -> Binder<[NSAttributedString.Key: Any]?> {
        return Binder(self.base) { view, attr in
            view.setTitleTextAttributes(attr, for: state)
        }
    }
    
}
