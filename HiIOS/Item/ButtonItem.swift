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
import ObjectMapper
import HiCore
import HiDomain

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

    public var height: CGFloat?
    public var style = ButtonStyle.plain
    public var titleColor: UIColor?
    public var backgroundColor: UIColor?
    public var tintColor: UIColor?
    public var initialState = State()

    required public init(_ model: any ModelType) {
        super.init(model)
        guard let info = model as? ButtonInfo else { return }
        height = info.height?.f
        style = info.style
        titleColor = info.titleColor?.color
        backgroundColor = info.backgroundColor?.color
        tintColor = info.tintColor?.color
        self.initialState = State(
            enabled: info.enabled,
            title: info.title
        )
    }
    
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .enable(isEnabled):
            return .just(.setEnabled(isEnabled))
        }
    }
        
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setEnabled(enabled):
            newState.enabled = enabled
        }
        return newState
    }
    
    open func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
}
