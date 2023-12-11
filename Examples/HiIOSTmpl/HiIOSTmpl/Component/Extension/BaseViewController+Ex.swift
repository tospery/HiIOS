//
//  BaseViewController+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import HiIOS

extension BaseViewController {
    
    @objc func myViewDidLoad() {
        self.myViewDidLoad()
//        if let url = self.parameters.string(for: Parameter.routerUrl) {
//            ALBBMANPageHitHelper.getInstance().updatePageProperties(self, properties: [
//                Parameter.url: url
//            ])
//        }
    }
    
    @objc func myViewDidAppear(_ animated: Bool) {
        self.myViewDidAppear(animated)
        // ALBBMANPageHitHelper.getInstance().pageAppear(self)
    }
    
    @objc func myViewDidDisappear(_ animated: Bool) {
        self.myViewDidDisappear(animated)
        // ALBBMANPageHitHelper.getInstance().pageDisAppear(self)
    }
    
//    @objc func myHandleTitle(_ text: String?) {
//        log("myHandleTitle")
//        Localizer.shared.localize(text ?? "")
//            .drive(self.navigationBar.titleLabel.rx.text)
//            .disposed(by: self.disposeBag)
//        self.navigationBar.setNeedsLayout()
//        self.navigationBar.layoutIfNeeded()
//    }
    
}
