//
//  UserListViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import ReusableKit
import ObjectMapper_Hi
import RxDataSources
import RxGesture
import HiIOS

class UserListViewController: ListViewController {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
        self.shouldRefresh = reactor.parameters.bool(for: Parameter.shouldRefresh) ?? true
        self.shouldLoadMore = reactor.parameters.bool(for: Parameter.shouldLoadMore) ?? (
            (reactor as? ListViewReactor)?.page == .trendingUsers ? false : true
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.pagingViewController != nil &&
            !self.scrollView.bounds.equalTo(self.view.bounds) {
            self.scrollView.frame = self.view.bounds
        }
    }
    
    override func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        var size = super.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
        if size.width > deviceWidth {
            size.width = deviceWidth
        }
        return size
    }
    
    override func handleContents(contents: [HiContent]) {
        guard let page = self.reactor?.page, page == .trendingUsers else { return }
        guard let users = contents.first?.models as? [User], users.isNotEmpty else { return }
        User.storeArray(users, page: page.rawValue)
        log("user缓存->\(page.rawValue)")
    }

}
