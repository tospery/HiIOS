//
//  PagingViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2023/1/25.
//

import Foundation

open class PagingViewReactor: ScrollViewReactor {

    /// The data source is responsible for providing the `PagingItem`s
    /// that are displayed in the menu. The `PagingItem` protocol is
    /// used to generate menu items for all the view controllers,
    /// without having to actually allocate them before they are needed.
    /// Use this property when you have a fixed amount of view
    /// controllers. If you need to support infinitely large data
    /// sources, use the infiniteDataSource property instead.
    public weak var dataSource: PagingViewControllerDataSource? {
        didSet {
            configureDataSource()
        }
    }
    
    /// A data source that can be used when you need to support
    /// infinitely large data source by returning the `PagingItem`
    /// before or after a given `PagingItem`. The `PagingItem` protocol
    /// is used to generate menu items for all the view controllers,
    /// without having to actually allocate them before they are needed.
    public weak var infiniteDataSource: PagingViewControllerInfiniteDataSource?
    
    private func configureDataSource() {
        let dataSource = PagingFiniteDataSource()
        dataSource.items = itemsForFiniteDataSource()
        dataSource.viewControllerForIndex = { [unowned self] in
            self.dataSource?.pagingViewController(self, viewControllerAt: $0)
        }

        dataSourceReference = .finite(dataSource)
        infiniteDataSource = dataSource

        if let firstItem = dataSource.items.first {
            pagingController.select(pagingItem: firstItem, animated: false)
        }
    }

    private func configureDataSource(for viewControllers: [UIViewController]) {
        let dataSource = PagingStaticDataSource(viewControllers: viewControllers)
        dataSourceReference = .static(dataSource)
        infiniteDataSource = dataSource
        if let pagingItem = dataSource.items.first {
            pagingController.select(pagingItem: pagingItem, animated: false)
        }
    }
    
}

extension PagingViewReactor: PagingMenuDataSource {
    public func pagingItemBefore(pagingItem: PagingItem) -> PagingItem? {
        return infiniteDataSource?.pagingViewController(self, itemBefore: pagingItem)
    }

    public func pagingItemAfter(pagingItem: PagingItem) -> PagingItem? {
        return infiniteDataSource?.pagingViewController(self, itemAfter: pagingItem)
    }
}

extension PagingViewReactor: PageViewControllerDataSource {
    
    open func pageViewController(_: PageViewController, viewControllerBeforeViewController _: UIViewController) -> UIViewController? {
        guard
            let dataSource = infiniteDataSource,
            let currentPagingItem = state.currentPagingItem,
            let pagingItem = dataSource.pagingViewController(self, itemBefore: currentPagingItem) else { return nil }

        return dataSource.pagingViewController(self, viewControllerFor: pagingItem)
    }

    open func pageViewController(_: PageViewController, viewControllerAfterViewController _: UIViewController) -> UIViewController? {
        guard
            let dataSource = infiniteDataSource,
            let currentPagingItem = state.currentPagingItem,
            let pagingItem = dataSource.pagingViewController(self, itemAfter: currentPagingItem) else { return nil }

        return dataSource.pagingViewController(self, viewControllerFor: pagingItem)
    }
    
}
