//
//  BaseViewController+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import SwifterSwift
import URLNavigator_Hi

public extension Reactive where Base: BaseViewController {
    
    var title: Binder<String?> {
        Binder(self.base) { viewController, title in
            viewController.handleTitle(title)
        }
    }
    
    var activating: Binder<Bool> {
        Binder(self.base) { viewController, isActivating in
            viewController.handleActivating(isActivating)
        }
    }
    
    var toast: Binder<String> {
        Binder(self.base) { viewController, message in
            viewController.handleToast(message)
        }
    }
    
    var error: Binder<Error?> {
        Binder(self.base) { viewController, error in
            viewController.handleError(error)
        }
    }
}

