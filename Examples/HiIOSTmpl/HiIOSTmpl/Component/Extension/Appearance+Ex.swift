//
//  Appearance+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import HiIOS

extension Appearance: AppearanceCompatible {
    
    public func myConfig() {
        self.basic()
        // 导航栏
//        let navBar = NavigationBar.appearance()
//        themeService.rx
//            .bind({ $0.primaryColor }, to: navBar.rx.itemColor)
//            .bind({ $0.lightColor }, to: navBar.rx.barColor)
//            .bind({ $0.borderColor }, to: navBar.rx.lineColor)
//            .bind({ $0.titleColor }, to: navBar.rx.titleColor)
//            .disposed(by: self.disposeBag)
        // 导航项
//        let barItem = UIBarButtonItem.appearance()
//        themeService.rx
//            .bind({ $0.primaryColor }, to: barItem.rx.tintColor)
//            .disposed(by: self.disposeBag)
    }
    
}
