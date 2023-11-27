//
//  Runtime+Ex.swift
//  IOSTemplate
//
//  Created by liaoya on 2022/2/15.
//

import UIKit
import QMUIKit
import HiIOS

extension Runtime: RuntimeCompatible {
    
    public func myWork() {
        ExchangeImplementations(UIApplication.self,
                                #selector(getter: UIApplication.baseApiUrl),
                                #selector(getter: UIApplication.myBaseApiUrl))
        ExchangeImplementations(UIApplication.self,
                                #selector(getter: UIApplication.baseWebUrl),
                                #selector(getter: UIApplication.myBaseWebUrl))
        ExchangeImplementations(ScrollViewController.self,
                                #selector(ScrollViewController.setupRefresh(should:)),
                                #selector(ScrollViewController.mySetupRefresh(should:)))
        ExchangeImplementations(ScrollViewController.self,
                                #selector(ScrollViewController.setupLoadMore(should:)),
                                #selector(ScrollViewController.mySetupLoadMore(should:)))
    }
    
}
