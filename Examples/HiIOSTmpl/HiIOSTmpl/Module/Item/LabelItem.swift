//
//  LabelItem.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/10.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import HiIOS

class LabelItem: BaseCollectionItem, ReactorKit.Reactor {

    typealias Action = NoAction
    typealias Mutation = NoMutation
    
    struct State {
        var info: LabelInfo?
    }

    var initialState = State()

    required public init(_ model: ModelType) {
        super.init(model)
        guard let element = (model as? BaseModel)?.data as? SectionItemElement else { return }
        if case let .label(info) = element {
            self.initialState = State(
                info: info
            )
        }
    }
    
}
