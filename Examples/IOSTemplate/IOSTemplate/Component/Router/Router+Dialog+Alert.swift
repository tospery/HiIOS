//
//  Router+Dialog+Alert.swift
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
    
    // swiftlint:disable function_body_length
    func alert(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .alert)) { url, _, context -> Bool in
            let title = url.queryParameters[Parameter.title]
            let message = url.queryParameters[Parameter.message]
            if title?.isEmpty ?? true && message?.isEmpty ?? true {
                return false
            }
            
            let ctx = context as? [String: Any]
            let observer = ctx?[Parameter.routerObserver] as? AnyObserver<Any>
            
            var actions = context as? [AlertActionType]
            if actions == nil {
                actions = ctx?[Parameter.actions] as? [AlertActionType] ?? []
            }
            if actions?.isEmpty ?? true {
                if let actionsString = ctx?[Parameter.actions] as? String, actionsString.isNotEmpty {
                    let string = actionsString
                    let data = string.data(using: .utf8)
                    let json = try? data?.jsonObject()
                    let array = json as? [String] ?? []
                    for string in array {
                        if let action = ITAlertAction.init(string: string) {
                            actions?.append(action)
                        }
                    }
                }
            }
            
            var isInput = false
            for action in actions! {
                if let action = action as? ITAlertAction, action == .input {
                    isInput = true
                    break
                }
            }
            if isInput {
                return self.alertInput(title, message, actions!, observer)
            }
            
            let simpleMessage = EKSimpleMessage(
                title: .init(text: title ?? "", style: .init(
                                font: .systemFont(ofSize: 16),
                                color: .black,
                                alignment: .center)),
                description: .init(
                    text: message ?? "",
                    style: .init(
                        font: .systemFont(ofSize: 14),
                        color: .init(light: .title, dark: .title),
                        alignment: .center)
                )
            )
        
            let name = url.queryParameters[Parameter.name] ?? self.defaultAlertName()
            var buttons = [EKProperty.ButtonContent]()
            for action in actions! {
                let button = EKProperty.ButtonContent(
                    label: .init(
                        text: action.title ?? "",
                        style: .init(font: .systemFont(ofSize: 16), color: .init(light: .title, dark: .title))
                    ),
                    backgroundColor: .clear,
                    highlightedBackgroundColor: .clear) {
                        SwiftEntryKit.dismiss(.specific(entryName: name)) {
                            observer?.onNext(action)
                            observer?.onCompleted()
                        }
                }
                buttons.append(button)
            }
            
            let buttonsBarContent = EKProperty.ButtonBarContent(
                with: buttons,
                separatorColor: .clear,
                expandAnimatedly: false
            )
            let alertMessage = EKAlertMessage(simpleMessage: simpleMessage, buttonBarContent: buttonsBarContent)
            let alertMessageView = EKAlertMessageView(with: alertMessage)
            
            let attributes = self.attributes(name)
            SwiftEntryKit.display(entry: alertMessageView, using: attributes)
            return true
        }
    }
    // swiftlint:enable function_body_length

    func defaultAlertName() -> String {
        "Alert\(UInt64(round(Date.init().timeIntervalSince1970 * 1000)))"
    }
    
    func alertInput(
        _ title: String?,
        _ message: String?,
        _ actions: [AlertActionType],
        _ observer: AnyObserver<Any>?
    ) -> Bool {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = title
        }
        for action in actions {
            if action as? ITAlertAction == .input {
                continue
            }
            alertController.addAction(.init(title: action.title, style: action.style, handler: { _ in
                if action.style != .cancel {
                    observer?.onNext(alertController.textFields?.first?.text ?? "")
                }
                observer?.onCompleted()
            }))
        }
        UIViewController.topMost?.present(alertController, animated: true, completion: nil)
        return true
    }
    
}
