//
//  BindCollectionItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import ObjectMapper
import HiCore
import HiDomain

open class BindCollectionItem: BaseCollectionItem, ReactorKit.Reactor {
    
    public enum Action {
        case load
        case finish(Error?)
    }
        
    public enum Mutation {
        case setLoading(Bool)
        case setError(Error?)
        case setData(Any?)
    }

    public struct State {
        public var isLoading = false
        public var error: Error?
        public var data: Any?
    }

    public var param: Any? = nil
    public var initialState = State()
    
    required public init(_ model: any ModelType) {
        super.init(model)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
            return .concat([
                .just(.setError(nil)),
                .just(.setLoading(true)),
                self.request(),
                .just(.setLoading(false))
            ]).catch({
                .concat([
                    .just(.setError($0)),
                    .just(.setLoading(false))
                ])
            })
        case .finish(let error):
            return .concat([
                .just(.setError(error)),
                .just(.setLoading(false))
            ])
        }
    }
            
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setError(error):
            newState.error = error
        case let .setData(data):
            newState.data = data
        }
        return newState
    }
    
    open func transform(action: Observable<Action>) -> Observable<Action> {
        action
    }
    
    open func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        mutation
    }
    
    open func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
    open func load() -> Observable<Mutation> {
        .concat([
            .just(.setError(nil)),
            .just(.setLoading(true)),
            self.request(),
            .just(.setLoading(false))
        ]).catch({
            .concat([
                .just(.setError($0)),
                .just(.setLoading(false))
            ])
        })
    }
    
    open func request() -> Observable<Mutation> {
        .never()
    }
    
}

extension BindCollectionItem.Action {
    
    static func isLoad(_ action: BindCollectionItem.Action) -> Bool {
        if case .load = action {
            return true
        }
        return false
    }
    
}
