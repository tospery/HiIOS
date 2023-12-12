//
//  RepoViewReactor.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import HiIOS

class RepoViewReactor: ListViewReactor {
    
    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
        self.initialState = State(
            title: self.title ?? "仓库详情"
        )
    }

}
