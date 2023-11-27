//
//  PersonalViewController.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import ReusableKit_Hi
import ObjectMapper_Hi
import RxDataSources
import RxGesture
import HiIOS

class PersonalViewController: NormalViewController {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarService.value.reversed
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func bind(reactor: NormalViewReactor) {
        super.bind(reactor: reactor)
    }
    
    override func fromState(reactor: NormalViewReactor) {
        super.fromState(reactor: reactor)
    }
    
    override func tapUser(_: Void? = nil) {
        if self.reactor?.currentState.user?.isValid ?? false {
            self.navigator.forward(Router.shared.urlString(host: .profile))
            return
        }
        self.navigator.login()
    }

}
