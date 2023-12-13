//
//  TrendingViewController.swift
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
import MXParallaxHeader
import SnapKit
import HiIOS

class TrendingViewController: ScrollViewController, ReactorKit.View {
    
    lazy var paging: NavigationBarPagingViewController = {
        let paging = NavigationBarPagingViewController()
        paging.menuBackgroundColor = .clear
        paging.menuHorizontalAlignment = .center
        paging.borderOptions = .hidden
        paging.menuItemSize = .selfSizing(estimatedWidth: 100, height: navigationBarHeight)
        paging.theme.textColor = themeService.attribute { $0.foregroundColor }
        paging.theme.selectedTextColor = themeService.attribute { $0.primaryColor }
        paging.theme.indicatorColor = themeService.attribute { $0.primaryColor }
        return paging
    }()
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? TrendingViewReactor
        }
        super.init(navigator, reactor)
        self.tabBarItem.title = reactor.title ?? (reactor as? TrendingViewReactor)?.currentState.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(self.paging)
        self.view.addSubview(self.paging.view)
        self.paging.view.frame = self.scrollView.frame
        self.paging.didMove(toParent: self)
        self.paging.dataSource = self.reactor

        self.paging.collectionView.size = CGSize(width: self.view.width, height: navigationBarHeight)
        self.navigationBar.titleView = self.paging.collectionView

        // v1.0.0版本屏蔽该功能，完善功能后下个版本打开
//        self.navigationBar.addButtonToLeft(image: R.image.nav_menu()).rx.tap
//            .subscribeNext(weak: self, type(of: self).tapMenu)
//            .disposed(by: self.disposeBag)
        self.navigationBar.addButtonToRight(image: R.image.navbar_search()).rx.tap
            .subscribeNext(weak: self, type(of: self).tapSearch)
            .disposed(by: self.disposeBag)
    }
    
    func bind(reactor: TrendingViewReactor) {
        super.bind(reactor: reactor)
        // action
        self.rx.load.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        // state
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: self.rx.loading)
            .disposed(by: self.disposeBag)
    }

    func tapSearch(_: Void? = nil) {
        log("tapSearch")
//        self.navigator.fPresent(
//            Router.shared.urlString(host: .search, path: .history),
//            wrap: NavigationController.self,
//            animated: false
//        )
        
        self.navigator.rxPopup(.options, context: [
            Parameter.username: "myuser",
            Parameter.reponame: "myrepo",
            Parameter.selected: "true"
        ]).subscribe(onNext: { [weak self] result in
            guard let `self` = self else { return }
            log("result: \(result)")
//            var data = self.reactor?.currentState.data as? RepoViewReactor.Data
//            data?.branch = result as? Branch
//            self.reactor?.action.onNext(.data(data))
        }).disposed(by: self.disposeBag)
    }
    
    override func handleTheme(_ themeType: ThemeType) {
        self.paging.reloadMenu()
    }

}
