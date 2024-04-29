//
//  DatasetCollectionCell+Rx.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxViewController
import URLNavigator_Hi
import DZNEmptyDataSet
import BonMot
import MJRefresh

public extension Reactive where Base: DatasetCollectionCell {
    
    var load: ControlEvent<Void> {
        let source = Observable.merge([
            // self.base.rx.viewDidLoad.asObservable(),
            self.base.rx.emptyDataSet.asObservable()
        ])
        return ControlEvent(events: source)
    }
    
    var loading: Binder<Bool> {
        return Binder(self.base) { cell, isLoading in
            cell.isLoading = isLoading
            // guard cell.isViewLoaded else { return }
            guard let scrollView = cell.contentView as? UIScrollView else { return }
            scrollView.reloadEmptyDataSet()
            if isLoading {
                if cell.shouldLoadMore {
                    cell.setupLoadMore(should: false)
                }
            } else {
                if cell.error != nil {
                    cell.setupLoadMore(should: false)
                    return
                }
                if cell.shouldLoadMore {
                    cell.setupLoadMore(should: true)
                }
                if cell.noMoreData {
                    scrollView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    scrollView.mj_footer?.resetNoMoreData()
                }
            }
        }
    }
    
    var refreshing: Binder<Bool> {
        return Binder(self.base) { cell, isRefreshing in
            cell.isRefreshing = isRefreshing
            // guard viewController.isViewLoaded else { return }
            guard let scrollView = cell.contentView as? UIScrollView else { return }
            if !isRefreshing {
                scrollView.mj_header?.endRefreshing()
                if cell.noMoreData {
                    scrollView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    scrollView.mj_footer?.resetNoMoreData()
                }
            }
        }
    }
    
    var loadingMore: Binder<Bool> {
        return Binder(self.base) { cell, isLoadingMore in
            cell.isLoadingMore = isLoadingMore
            // guard viewController.isViewLoaded else { return }
            guard let scrollView = cell.contentView as? UIScrollView else { return }
            if !isLoadingMore {
                if cell.noMoreData {
                    scrollView.mj_footer?.endRefreshingWithNoMoreData()
                } else {
                    if case .listIsEmpty = cell.error as? HiError {
                        scrollView.mj_footer?.endRefreshingWithNoMoreData()
                    } else {
                        scrollView.mj_footer?.resetNoMoreData()
                    }
                }
            }
        }
    }
    
    var noMoreData: Binder<Bool> {
        return Binder(self.base) { viewController, noMoreData in
            viewController.noMoreData = noMoreData
//            guard viewController.isViewLoaded else { return }
//            guard let scrollView = viewController.scrollView else { return }
//            if noMoreData {
//                scrollView.mj_footer?.endRefreshingWithNoMoreData()
//            } else {
//                scrollView.mj_footer?.resetNoMoreData()
//            }
        }
    }
    
    var emptyDataSet: ControlEvent<Void> {
        let source = self.base.emptyDataSetSubject.map{ _ in }
        return ControlEvent(events: source)
    }
    
    var refresh: ControlEvent<Void> {
        let source = self.base.refreshSubject.map{ _ in }
        return ControlEvent(events: source)
    }
    
    var loadMore: ControlEvent<Void> {
        let source = self.base.loadMoreSubject.map{ _ in }
        return ControlEvent(events: source)
    }
    
    var startPullToRefresh: Binder<Void> {
        return Binder(self.base) { cell, _ in
            if let scrollView = cell.contentView as? UIScrollView {
                scrollView.mj_header?.beginRefreshing()
            }
        }
    }
    
    var error: Binder<Error?> {
        Binder(self.base) { cell, error in
            cell.handleError(error)
        }
    }
}
