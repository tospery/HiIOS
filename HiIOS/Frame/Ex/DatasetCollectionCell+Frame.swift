//
//  UICollectionViewCell+Frame.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import UIKit
import RxSwift
import RxCocoa
import URLNavigator_Hi
import DZNEmptyDataSet
import BonMot
import MJRefresh

extension DatasetCollectionCell {
    
    @objc dynamic open func setupRefresh(should: Bool) {
        guard let scrollView = self.contentView as? UIScrollView else { return }
        if should {
            scrollView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: { [weak self] in
                guard let `self` = self else { return }
                self.refreshSubject.onNext(())
            })
        } else {
            scrollView.mj_header?.removeFromSuperview()
            scrollView.mj_header = nil
        }
    }
    
    @objc dynamic open func setupLoadMore(should: Bool) {
        guard let scrollView = self.contentView as? UIScrollView else { return }
        if should {
            scrollView.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: { [weak self] in
                guard let `self` = self else { return }
                self.loadMoreSubject.onNext(())
            })
        } else {
            scrollView.mj_footer?.removeFromSuperview()
            scrollView.mj_footer = nil
        }
    }
    
    func handle(theme: ThemeType) {
        guard let scrollView = self.contentView as? UIScrollView else { return }
        scrollView.reloadEmptyDataSet()
    }
    
}
