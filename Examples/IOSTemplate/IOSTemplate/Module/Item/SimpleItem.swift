//
//  SimpleItem.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS

class SimpleItem: BaseCollectionItem, ReactorKit.Reactor {
    
    enum Action {
        case title(String?)
        case detail(String?)
    }
    
    enum Mutation {
        case setTitle(String?)
        case setDetail(String?)
    }
    
    struct State {
        var icon: ImageSource?
        var title: String?
        var detail: String?
        var indicated = true
        var divided = true
    }
    
    var isSpace = false
    var height: CGFloat?
    var color: UIColor?
    var initialState = State()
    
    required init(_ model: ModelType) {
        super.init(model)
        guard let simple = model as? Simple else { return }
        isSpace = simple.isSpace
        height = simple.height
        color = simple.color?.color
        self.initialState = State(
            icon: simple.icon?.imageSource,
            title: simple.title,
            detail: simple.detail,
            indicated: simple.indicated ?? false,
            divided: simple.divided ?? false
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .title(title):
            return .just(.setTitle(title))
        case let .detail(detail):
            return .just(.setDetail(detail))
        }
    }
        
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTitle(title):
            newState.title = title
        case let .setDetail(detail):
            newState.detail = detail
        }
        return newState
    }
    
    func transform(action: Observable<NoAction>) -> Observable<NoAction> {
        action
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        mutation
    }

    func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
}
