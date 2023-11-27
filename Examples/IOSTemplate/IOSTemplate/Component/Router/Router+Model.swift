//
//  MyRouter+Model.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
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
    
    public func model(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        self.toast(provider, navigator)
        self.alert(provider, navigator)
        self.sheet(provider, navigator)
        self.popup(provider, navigator)
    }
    
    func toast(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .toast)) { url, _, _ -> Bool in
            guard let window = AppDependency.shared.window else { return false }
            if let message = url.queryParameters[Parameter.message] {
                window.makeToast(message)
            } else if let active = url.queryParameters[Parameter.active] {
                window.isUserInteractionEnabled = !(active.bool ?? false)
                (active.bool ?? false) ? window.makeToastActivity(.center) : window.hideToastActivity()
            } else {
                return false
            }
            return true
        }
    }
    
    // swiftlint:disable function_body_length
    func alert(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .alert)) { url, _, context -> Bool in
            let title = url.queryParameters[Parameter.title]
            let message = url.queryParameters[Parameter.message]
            if title?.isEmpty ?? true && message?.isEmpty ?? true {
                return false
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
        
            let ctx = context as? [String: Any]
            let observer = ctx?[Parameter.observer] as? AnyObserver<Any>
            
            var actions = context as? [AlertActionType]
            if actions == nil {
                actions = ctx?[Parameter.actions] as? [AlertActionType] ?? []
            }
            
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
    
    func sheet(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
    }
    
    func popup(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        navigator.handle(self.urlPattern(host: .popup)) { url, values, context -> Bool in
            guard let popup = url.urlValue?.path.removingPrefix("/").removingSuffix("/") else { return false }
            let parameters = self.parameters(url, values, context)
            switch popup {
            case .inviteNew:
                return self.popupInviteNew(provider, navigator, parameters)
            default:
                return false
            }
        }
    }
    
    // MARK: - Popup
    func popupInviteNew(
        _ provider: HiIOS.ProviderType,
        _ navigator: NavigatorProtocol,
        _ parameters: [String: Any]?
    ) -> Bool {
        return true
    }
    
    // MARK: - Name
    func defaultAlertName() -> String {
        "Alert\(UInt64(round(Date.init().timeIntervalSince1970 * 1000)))"
    }
    
    func defaultPopupName() -> String {
        "Popup\(UInt64(round(Date.init().timeIntervalSince1970 * 1000)))"
    }
    
    // MARK: - Attributes
    func attributes(_ name: String?) -> EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.windowLevel = .normal
        attributes.statusBar = .ignored
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: EKColor(light: .light, dark: .dark))
        attributes.entryBackground = .color(color: .white)
        attributes.entranceAnimation = .init(
            scale: .init(
                from: 0.8,
                to: 1.0,
                duration: 0.5,
                spring: .init(
                    damping: 0.3,
                    initialVelocity: 10
                )
            )
        )
        attributes.exitAnimation = .init(
            scale: .init(
                from: 1,
                to: 0.8,
                duration: 0.3
            ),
            fade: .init(
                from: 1,
                to: 0,
                duration: 0.3
            )
        )
        attributes.popBehavior = .animated(
            animation: .init(
                scale: .init(
                    from: 1,
                    to: 0.8,
                    duration: 0.3
                ),
                fade: .init(
                    from: 1,
                    to: 0,
                    duration: 0.3
                )
            )
        )
        attributes.name = name
        return attributes
    }
    
}
