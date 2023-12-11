//
//  TextFieldItem.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/11.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import HiIOS

class TextFieldItem: BaseCollectionItem, ReactorKit.Reactor {

    typealias Action = NoAction
    typealias Mutation = NoMutation

    struct State {
        var text: String?
    }

    var initialState = State()

    required public init(_ model: ModelType) {
        super.init(model)
        guard let element = (model as? BaseModel)?.data as? SectionItemElement else { return }
        if case let .textField(text) = element {
            self.initialState = State(
                text: text
            )
        }
    }
    
}
