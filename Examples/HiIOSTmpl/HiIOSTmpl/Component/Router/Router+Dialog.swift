//
//  Router+Dialog.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import Toast_Swift
import SwiftEntryKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import HiIOS

extension Router {
    
    public func dialog(_ provider: HiIOS.ProviderType, _ navigator: NavigatorProtocol) {
        self.toast(provider, navigator)
        self.alert(provider, navigator)
        self.sheet(provider, navigator)
        self.popup(provider, navigator)
    }
    
    // swiftlint:disable function_body_length
    func attributes(_ name: String?) -> EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.windowLevel = .normal
        attributes.statusBar = .ignored
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .absorbTouches
        attributes.entryInteraction = .absorbTouches
        attributes.scroll = .disabled
        attributes.screenBackground = .color(color: .init(
            light: .foreground.withAlphaComponent(0.4),
            dark: .background.withAlphaComponent(0.4)
        ))
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
    // swiftlint:enable function_body_length
    
}
