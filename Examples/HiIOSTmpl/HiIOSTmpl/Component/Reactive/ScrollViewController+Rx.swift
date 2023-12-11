//
//  ScrollViewController+Rx.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/11.
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
