//
//  TabBarController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
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
        self.delegate = self
        self.tabBar.theme.barTintColor = themeService.attribute { $0.lightColor }
        self.tabBar.theme.tintColor = themeService.attribute { $0.primaryColor }
        self.tabBar.theme.unselectedItemTintColor = themeService.attribute { $0.titleColor }
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
        case .event:
            viewController = self.navigator.viewController(
                for: Router.shared.urlString(host: .event)
            )
            viewController.tabBarItem.image = R.image.tabbar_event_normal()?.original
            viewController.tabBarItem.selectedImage = R.image.tabbar_event_selected()?.template
        case .favorite:
            viewController = self.navigator.viewController(
                for: Router.shared.urlString(host: .favorite)
            )
            viewController.tabBarItem.image = R.image.tabbar_favorite_normal()?.original
            viewController.tabBarItem.selectedImage = R.image.tabbar_favorite_selected()?.template
        case .personal:
            viewController = self.navigator.viewController(
                for: Router.shared.urlString(host: .personal, parameters: [
                    Parameter.transparetNavBar: true.string
                ])
            )
            viewController.tabBarItem.image = R.image.tabbar_personal_normal()?.original
            viewController.tabBarItem.selectedImage = R.image.tabbar_personal_selected()?.template
        }
        viewController.hidesBottomBarWhenPushed = false
        return viewController!
    }

}

extension TabBarController: UITabBarControllerDelegate {

    func tabBarController(
        _ tabBarController: UITabBarController,
        shouldSelect viewController: UIViewController
    ) -> Bool {
//        guard let index = tabBarController.viewControllers?.firstIndex(of: viewController) else { return true }
//        if index == 1 || index == 2 {
//            if User.current?.isValid ?? false {
//                return true
//            }
//            self.navigator.rxLogin().subscribe(onNext: { _ in
//                tabBarController.selectedIndex = index
//            }).disposed(by: self.disposeBag)
//            return false
//        }
        return true
    }

}
