//
//  SimpleItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/3/21.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi

open class SimpleItem: BaseCollectionItem, ReactorKit.Reactor {
    
    public enum Action {
        case title(String?)
        case detail(String?)
    }
    
    public enum Mutation {
        case setTitle(String?)
        case setDetail(String?)
        case setIcon(ImageSource?)
    }
    
    public struct State {
        public var icon: ImageSource?
        public var title: String?
        public var detail: String?
        public var indicated = true
        public var divided = true
    }
    
    public var isSpace = false
    public var height: CGFloat?
    public var color: UIColor?
    public var tintColor: UIColor?
    public var initialState = State()
    
    required public init(_ model: ModelType) {
        super.init(model)
        guard let simple = model as? Simple else { return }
        isSpace = simple.isSpace
        height = simple.height
        color = simple.color?.color
        tintColor = simple.tintColor?.color
        self.initialState = State(
            icon: simple.icon?.imageSource,
            title: simple.title,
            detail: simple.detail,
            indicated: simple.indicated ?? false,
            divided: simple.divided ?? false
        )
    }
    
    open func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .title(title):
            return .just(.setTitle(title))
        case let .detail(detail):
            return .just(.setDetail(detail))
        }
    }
        
    open func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTitle(title):
            newState.title = title
        case let .setDetail(detail):
            newState.detail = detail
        case let .setIcon(icon):
            newState.icon = icon
        }
        return newState
    }
    
    open func transform(action: Observable<NoAction>) -> Observable<NoAction> {
        action
    }

    open func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        mutation
    }

    open func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
}
