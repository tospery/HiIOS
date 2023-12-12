//
//  UserViewReactor.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import HiIOS

class UserViewReactor: ListViewReactor {
    
    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title ?? "用户详情"
        )
    }

}
