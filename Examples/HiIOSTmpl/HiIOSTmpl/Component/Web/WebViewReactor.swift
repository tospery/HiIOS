//
//  WebViewReactor.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import HiIOS

class WebViewReactor: HiIOS.WebViewReactor {

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
    }

}
