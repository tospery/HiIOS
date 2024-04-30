//
//  DatasetCollectionCell+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import URLNavigator_Hi
import DZNEmptyDataSet
import BonMot
import MJRefresh

public extension Reactive where Base: DatasetCollectionCell {
    
    var load: ControlEvent<Void> {
        let source = Observable.merge([
            // self.base.rx.initWithFrame.asObservable(),
            self.base.rx.emptyDataSet.asObservable()
        ])
        return ControlEvent(events: source)
    }
    
    var loading: Binder<Bool> {
        return Binder(self.base) { cell, isLoading in
            cell.isLoading = isLoading
            // guard cell.isViewLoaded else { return }
            cell.scrollView.reloadEmptyDataSet()
        }
    }
    
    var emptyDataSet: ControlEvent<Void> {
        let source = self.base.emptyDataSetSubject.map{ _ in }
        return ControlEvent(events: source)
    }
    
    var error: Binder<Error?> {
        Binder(self.base) { cell, error in
            cell.handleError(error)
        }
    }
}
