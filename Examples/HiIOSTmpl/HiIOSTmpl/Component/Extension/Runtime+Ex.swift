//
//  Runtime+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import UIKit
import QMUIKit
import HiIOS

extension Runtime: RuntimeCompatible {
    
    public func myWork() {
        self.basic()
        ExchangeImplementations(UIApplication.self,
                                #selector(getter: UIApplication.baseApiUrl),
                                #selector(getter: UIApplication.myBaseApiUrl))
        ExchangeImplementations(UIApplication.self,
                                #selector(getter: UIApplication.baseWebUrl),
                                #selector(getter: UIApplication.myBaseWebUrl))
        ExchangeImplementations(UIApplication.self,
                                #selector(getter: UIApplication.pageSize),
                                #selector(getter: UIApplication.myPageSize))
        ExchangeImplementations(BaseViewController.self,
                                #selector(BaseViewController.viewDidLoad),
                                #selector(BaseViewController.myViewDidLoad))
        ExchangeImplementations(BaseViewController.self,
                                #selector(BaseViewController.viewDidAppear(_:)),
                                #selector(BaseViewController.myViewDidAppear(_:)))
        ExchangeImplementations(BaseViewController.self,
                                #selector(BaseViewController.viewDidDisappear(_:)),
                                #selector(BaseViewController.myViewDidDisappear(_:)))
//        ExchangeImplementations(BaseViewController.self,
//                                #selector(BaseViewController.handleTitle(_:)),
//                                #selector(BaseViewController.myHandleTitle(_:)))
        ExchangeImplementations(ScrollViewController.self,
                                #selector(ScrollViewController.setupRefresh(should:)),
                                #selector(ScrollViewController.mySetupRefresh(should:)))
        ExchangeImplementations(ScrollViewController.self,
                                #selector(ScrollViewController.setupLoadMore(should:)),
                                #selector(ScrollViewController.mySetupLoadMore(should:)))
    }
    
}
