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
import HiCore
import HiDomain
import HiNav

open class BaseViewReactor: NSObject, ReactorType {
    
    public let host: HiNav.Host
    public let path: HiNav.Path?
    public let provider: ProviderProtocol
    public weak var navigator: NavigatorProtocol!
    public var parameters: [String: Any]
    public var title: String?
    public let mydealloc = PublishSubject<Void>.init()
    public var disposeBag = DisposeBag()
    
    required public init(_ provider: ProviderProtocol, _ parameters: [String: Any]?) {
        self.host = parameters?.string(for: Parameter.navHost) ?? .login
        self.path = parameters?.string(for: Parameter.navPath)
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
