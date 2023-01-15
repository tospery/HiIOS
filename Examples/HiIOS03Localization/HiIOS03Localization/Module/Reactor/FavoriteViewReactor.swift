//
//  FavoriteViewReactor.swift
//  HiIOS01TabBar
//
//  Created by 杨建祥 on 2023/1/14.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import HiIOS

class FavoriteViewReactor: ScrollViewReactor, ReactorKit.Reactor {

    enum Action {
        case load
    }

    enum Mutation {
        case setTitle(String?)
    }

    struct State {
        var title: String?
    }

    var initialState = State()

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title ?? R.string.localizable.favorite()
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load: return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTitle(title):
            newState.title = title
        }
        return newState
    }
    
}
