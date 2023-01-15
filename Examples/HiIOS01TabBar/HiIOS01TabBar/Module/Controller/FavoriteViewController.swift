//
//  FavoriteViewController.swift
//  HiIOS01TabBar
//
//  Created by 杨建祥 on 2023/1/14.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RxViewController
import HiIOS

class FavoriteViewController: ScrollViewController, ReactorKit.View {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? FavoriteViewReactor
        }
        super.init(navigator, reactor)
        self.tabBarItem.title = reactor.title ?? (reactor as? FavoriteViewReactor)?.currentState.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(reactor: FavoriteViewReactor) {
        super.bind(reactor: reactor)
        // action
        self.rx.viewDidLoad.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
        // state
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.rx.title)
            .disposed(by: self.disposeBag)
    }
    
}

