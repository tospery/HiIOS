//
//  TileItem.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/3/21.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi

open class TileItem: BaseCollectionItem, ReactorKit.Reactor {
    
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
        public var checked = false
    }
    
    public var isSpace = false
    public var height: CGFloat?
    public var color: UIColor?
    public var tintColor: UIColor?
    public var initialState = State()
    
    required public init(_ model: any ModelType) {
        super.init(model)
        guard let tile = model as? Tile else { return }
        isSpace = tile.isSpace
        height = tile.height
        color = tile.color?.color
        tintColor = tile.tintColor?.color
        self.initialState = State(
            icon: tile.icon?.imageSource,
            title: tile.title,
            detail: tile.detail,
            indicated: tile.indicated ?? false,
            divided: tile.divided ?? false,
            checked: tile.checked ?? false
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
