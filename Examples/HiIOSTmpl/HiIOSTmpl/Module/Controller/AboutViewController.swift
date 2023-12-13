//
//  AboutViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import ReusableKit
import URLNavigator_Hi
import ObjectMapper_Hi
import RswiftResources
import RxDataSources
import RxGesture
import MessageUI
import HiIOS

class AboutViewController: ListViewController {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
