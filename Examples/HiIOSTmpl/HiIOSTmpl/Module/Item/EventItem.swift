//
//  EventItem.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import HiIOS

class EventItem: BaseCollectionItem, ReactorKit.Reactor {

    typealias Action = NoAction

    enum Mutation {
        case setTitle(String?)
    }

    struct State {
        var title: String?
    }

    var initialState = State()

    required public init(_ model: ModelType) {
        super.init(model)
        guard let event = model as? Event else { return }
        self.initialState = State(
            title: event.id
        )
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setTitle(title):
            newState.title = title
        }
        return newState
    }

//    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
//        .merge(
//           mutation,
//           themeService.typeStream.skip(1)
//            .map { [weak self] _ -> String? in
//                guard let `self` = self else { return nil }
//                guard let event = self.model as? Event else { return nil }
//                return event.id
//            }
//            .map(Mutation.setTitle)
//       )
//    }
    
}
