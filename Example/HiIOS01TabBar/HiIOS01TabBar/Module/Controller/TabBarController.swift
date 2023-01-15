//
//  TabBarController.swift
//  HiIOS01TabBar
//
//  Created by 杨建祥 on 2023/1/14.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import HiIOS

class TabBarController: HiIOS.TabBarController, ReactorKit.View {

    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? TabBarReactor
        }
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = .lightGray
        self.tabBar.tintColor = .blue
        self.tabBar.unselectedItemTintColor = .black
    }

    func bind(reactor: TabBarReactor) {
        super.bind(reactor: reactor)
        reactor.state.map { $0.keys }
            .take(until: self.rx.viewDidLoad)
            .subscribe(onNext: { [weak self] keys in
                guard let `self` = self else { return }
                self.viewControllers = keys.map {
                    NavigationController(rootViewController: self.viewController(with: $0))
                }
            })
            .disposed(by: self.disposeBag)
    }

    func viewController(with key: TabBarKey) -> UIViewController {
        var viewController: UIViewController!
        switch key {
        case .trending:
            viewController = TrendingViewController(
                self.navigator,
                TrendingViewReactor.init(AppDependency.shared.provider, nil)
            )
            viewController.tabBarItem.image = UIImage.init(named: "tabbar_trending_normal")?.original
            viewController.tabBarItem.selectedImage = UIImage.init(named: "tabbar_trending_selected")?.original
        case .favorite:
            viewController = FavoriteViewController(
                self.navigator,
                FavoriteViewReactor.init(AppDependency.shared.provider, nil)
            )
            viewController.tabBarItem.image = UIImage.init(named: "tabbar_favorite_normal")?.original
            viewController.tabBarItem.selectedImage = UIImage.init(named: "tabbar_favorite_selected")?.original
        case .personal:
            viewController = PersonalViewController(
                self.navigator,
                PersonalViewReactor.init(AppDependency.shared.provider, nil)
            )
            viewController.tabBarItem.image = UIImage.init(named: "tabbar_personal_normal")?.original
            viewController.tabBarItem.selectedImage = UIImage.init(named: "tabbar_personal_selected")?.original
        }
        viewController.hidesBottomBarWhenPushed = false
        return viewController!
    }

}
