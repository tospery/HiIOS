//
//  Router+Dialog+Sheet.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2023/11/27.
//

import UIKit
import Toast_Swift
import SwiftEntryKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS

extension Router {
    
    func sheet(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .sheet)) { url, _, context -> Bool in
            let title = url.queryParameters[Parameter.title]
            let message = url.queryParameters[Parameter.message]
            let alertController = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .actionSheet
            )
            
            let ctx = context as? [String: Any]
            let observer = ctx?[Parameter.routerObserver] as? AnyObserver<Any>
            var actions = context as? [AlertActionType] ?? []
            if actions.isEmpty {
                if let actionsString = url.queryParameters[Parameter.actions], actionsString.isNotEmpty {
                    let string = actionsString
                    let data = string.data(using: .utf8)
                    let json = try? data?.jsonObject()
                    let array = json as? [String] ?? []
                    for string in array {
                        if let action = ITAlertAction.init(string: string) {
                            actions.append(action)
                        }
                    }
                }
            }
            if actions.isEmpty {
                actions = ctx?[Parameter.actions] as? [AlertActionType] ?? []
            }
            for action in actions {
                alertController.addAction(.init(title: action.title, style: action.style, handler: { _ in
                    observer?.onNext(action)
                    observer?.onCompleted()
                }))
            }
            UIViewController.topMost?.present(alertController, animated: true, completion: nil)
            return true
        }
    }

}
