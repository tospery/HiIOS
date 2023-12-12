//
//  BaseViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import RxSwift
import RxCocoa
import URLNavigator_Hi

open class BaseViewReactor: NSObject, ReactorType {
    
    public let host: Router.Host
    public let path: Router.Path?
    public let provider: ProviderType
    public weak var navigator: NavigatorProtocol!
    public var parameters: [String: Any]
    public var title: String?
    public let mydealloc = PublishSubject<Void>.init()
    public var disposeBag = DisposeBag()
    
    required public init(_ provider: ProviderType, _ parameters: [String: Any]?) {
        self.host = parameters?.string(for: Parameter.routerHost) ?? .login
        self.path = parameters?.string(for: Parameter.routerPath)
        self.provider = provider
        self.parameters = parameters ?? [:]
        self.title = self.parameters.string(for: Parameter.title)
    }
    
    deinit {
        #if DEBUG
        logger.print("\(self.className)已销毁！！！", module: .hiIOS)
        #endif
    }
    
}
