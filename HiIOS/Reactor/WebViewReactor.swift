//
//  WebViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import ReactorKit
import HiCore
import HiDomain

open class WebViewReactor: ScrollViewReactor, ReactorKit.Reactor {
    
    public typealias Action = NoAction
    
    public struct State {
        var title: String?
    }
    
    public var initialState = State()
    
    public required init(_ provider: ProviderProtocol, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        var handlers = self.parameters[Parameter.handers] as? [String] ?? []
        handlers.append("appHandler")
        self.parameters[Parameter.handers] = handlers
        self.initialState = State(
            title: self.title
        )
    }
    
}
