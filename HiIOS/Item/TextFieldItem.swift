//
//  TextFieldItem.swift
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

open class TextFieldItem: BaseCollectionItem, ReactorKit.Reactor {

    public typealias Action = NoAction
    public typealias Mutation = NoMutation

    public struct State {
        public var text: String?
    }

    public var initialState = State()

    required public init(_ model: any ModelType) {
        super.init(model)
    }
    
}
