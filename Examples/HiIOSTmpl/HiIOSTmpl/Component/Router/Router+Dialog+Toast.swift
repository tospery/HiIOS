//
//  Router+Dialog+Toast.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import Toast_Swift
import SwiftEntryKit
import HiIOS

extension Router {
    
    func toast(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .toast)) { url, _, _ -> Bool in
            guard let window = AppDependency.shared.window else { return false }
            if let message = url.queryParameters[Parameter.message] {
                window.makeToast(message)
            } else if let active = url.queryParameters[Parameter.active] {
                window.isUserInteractionEnabled = !(active.bool ?? false)
                if active.bool ?? false {
                    window.makeToastActivity(.center)
                } else {
                    window.hideToastActivity()
                }
            } else {
                return false
            }
            return true
        }
    }

}
