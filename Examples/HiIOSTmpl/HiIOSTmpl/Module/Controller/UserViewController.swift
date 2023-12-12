//
//  UserViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RswiftResources
import ReusableKit
import ObjectMapper_Hi
import RxDataSources
import RxGesture
import HiIOS

class UserViewController: ListViewController {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
