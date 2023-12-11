//
//  ScrollViewController+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import MJRefresh
import HiIOS

extension ScrollViewController {
    
    @objc func mySetupRefresh(should: Bool) {
//        if should {
//            let header = SWRefreshHeader.init(refreshingBlock: { [weak self] in
//                guard let `self` = self else { return }
//                self.refreshSubject.onNext(())
//            })
//            header.lastUpdatedTimeLabel?.isHidden = true
//            header.stateLabel?.isHidden = true
//            self.scrollView.mj_header = header
//        } else {
//            self.scrollView.mj_header?.removeFromSuperview()
//            self.scrollView.mj_header = nil
//        }
        self.mySetupRefresh(should: should)
    }
    
    @objc func mySetupLoadMore(should: Bool) {
        self.mySetupLoadMore(should: should)
    }
    
}
