//
//  WebViewReactor.swift
//  IOSTemplate
//
//  Created by liaoya on 2021/6/28.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS

class WebViewReactor: HiIOS.WebViewReactor {

    required init(_ provider: HiIOS.ProviderType, _ parameters: [String: Any]?) {
        super.init(provider, parameters)
    }

}
