//
//  TabBarReactor.swift
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

class TabBarReactor: HiIOS.TabBarReactor, ReactorKit.Reactor {

    typealias Action = NoAction

    struct State {
        let keys: [TabBarKey] = [
            .trending, .favorite, .personal
        ]
    }

    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
    }

}

