//
//  SimpleItem.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import RswiftResources
import HiIOS

class SimpleItem: BaseCollectionItem, ReactorKit.Reactor {
    
    enum Action {
        case title(String?)
        case detail(String?)
    }
    
    enum Mutation {
        case setTitle(String?)
        case setDetail(String?)
        case setIcon(ImageSource?)
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
    var tintColor: UIColor?
    var initialState = State()
    
    required init(_ model: ModelType) {
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
        case let .setIcon(icon):
            newState.icon = icon
        }
        return newState
    }
    
    func transform(action: Observable<NoAction>) -> Observable<NoAction> {
        action
    }

    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        .merge(
           mutation,
           Subjection.for(Configuration.self).map { $0?.localization }
               .distinctUntilChanged()
               .skip(1)
               .flatMap { [weak self] _ -> Observable<Mutation> in
                   guard let `self` = self else { return .empty() }
                   guard let simple = self.model as? Simple else { return .empty() }
                   guard let cellId = CellId.init(rawValue: simple.id) else { return .empty() }
                   return .merge([
                       .just(.setTitle(cellId.title)),
                       .just(.setIcon(cellId.icon?.imageSource))
                   ])
               }
       )
    }

    func transform(state: Observable<State>) -> Observable<State> {
        state
    }
    
}
