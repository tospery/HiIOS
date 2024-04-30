//
//  UICollectionViewCell+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import UIKit
import RxCocoa
import RxSwift

public extension Reactive where Base: UICollectionViewCell {
    var initWithFrame: ControlEvent<Void> {
        let source = self.methodInvoked(#selector(Base.init(frame:))).map { _ in }
        return ControlEvent(events: source)
    }
}
