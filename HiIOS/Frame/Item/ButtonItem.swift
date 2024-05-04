//
//  ButtonItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/5.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi

open class ButtonItem: BaseCollectionItem, ReactorKit.Reactor {

    public enum Action {
        case enable(Bool?)
    }
    
    public enum Mutation {
        case setEnabled(Bool?)
    }

    public struct State {
        public var enabled: Bool?
        public var title: String?
    }

    public var initialState = State()

    required public init(_ model: any ModelType) {
        super.init(model)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .enable(isEnabled):
            return .just(.setEnabled(isEnabled))
        }
    }
        
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setEnabled(enabled):
            newState.enabled = enabled
        }
        return newState
    }
    
}
