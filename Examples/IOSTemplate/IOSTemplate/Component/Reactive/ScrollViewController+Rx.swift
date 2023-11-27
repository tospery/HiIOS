//
//  ScrollViewController+Rx.swift
//  IOSTemplate
//
//  Created by liaoya on 2021/6/28.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import HiIOS

extension Reactive where Base: ScrollViewController {
    
    var load: ControlEvent<Void> {
        let source = Observable.merge([
            self.base.rx.viewDidLoad.asObservable(),
            self.base.rx.emptyDataSet.asObservable()
        ])
        return ControlEvent(events: source)
    }
    
}
