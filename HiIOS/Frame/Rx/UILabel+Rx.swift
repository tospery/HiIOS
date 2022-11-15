//
//  UILabel+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UILabel {

    public var isHighlighted: Binder<Bool> {
        return Binder(self.base) { label, highlighted in
            label.isHighlighted = highlighted
        }
    }

}
