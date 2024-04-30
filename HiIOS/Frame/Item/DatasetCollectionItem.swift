//
//  DatasetCollectionItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/4/30.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit

open class DatasetCollectionItem: BaseCollectionItem, ReactorKit.Reactor {
    
    public enum Action {
        case load
        case data(Any?)
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
        case let .data(data): 
            return .just(.setData(data))
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
    
    open func request() -> Observable<Mutation> {
        .empty()
    }
    
}

extension DatasetCollectionItem.Action {
    
    static func isLoad(_ action: DatasetCollectionItem.Action) -> Bool {
        if case .load = action {
            return true
        }
        return false
    }
    
}
