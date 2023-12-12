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
import URLNavigator
import RswiftResources
import ReusableKit
import ObjectMapper_Hi
import RxDataSources
import RxGesture
import HiIOS

class UserViewController: ListViewController {
    
    lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = .normal(17)
        button.backgroundColor = .red
        button.setTitle("User", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.sizeToFit()
        return button
    }()
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.button)
        self.button.rx.tap
            .subscribeNext(weak: self, type(of: self).tapTest)
            .disposed(by: self.rx.disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.button.left = self.button.leftWhenCenter
        self.button.top = self.button.topWhenCenter
    }
    
    func tapTest(_: Void? = nil) {
//        self.navigator.rxBack()
//            .subscribe(onCompleted: { [weak self] in
//                guard let `self` = self else { return }
//                self.callback?.onNext("abc123")
//                self.callback?.onCompleted()
//            })
//            .disposed(by: self.disposeBag)
    }

}
