//
//  PortalItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

open class PortalItem: BaseCollectionItem, ReactorKit.Reactor {
    
    public enum Action {
        case title(String?)
        case detail(String?)
    }
    
    public enum Mutation {
        case setTitle(String?)
        case setDetail(String?)
    }
    
    public struct State {
        public var icon: ImageSource?
        public var title: String?
        public var detail: String?
        public var indicated = true
    }
    
    public var initialState = State()
    
    required public init(_ model: ModelType) {
        super.init(model)
        guard let portal = model as? Portal else { return }
        self.initialState = State(
            icon: portal.icon?.imageSource,
            title: portal.title,
            detail: portal.detail,
            indicated: portal.indicated
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .title(title):
            return .just(.setTitle(title))
        case let .detail(detail):
            return .just(.setDetail(detail))
        }
    }
        
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTitle(title):
            newState.title = title
        case let .setDetail(detail):
            newState.detail = detail
        }
        return newState
    }
    
    public func transform(action: Observable<NoAction>) -> Observable<NoAction> {
        action
    }

    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        mutation
    }

    public func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
}
