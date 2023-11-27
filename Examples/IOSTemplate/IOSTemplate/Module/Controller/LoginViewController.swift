//
//  LoginViewController.swift
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
import HiIOS

class LoginViewController: ScrollViewController, ReactorKit.View {
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        defer {
            self.reactor = reactor as? LoginViewReactor
        }
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bind(reactor: LoginViewReactor) {
        super.bind(reactor: reactor)
        // action
        self.rx.load.map { Reactor.Action.load }
            .bind(to: reactor.action)
            .disposed(by: self.disposeBag)
//        self.usernameView.usernameTextField.rx.text
//            .map { $0?.trimmed }
//            .map { Reactor.Action.username($0) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
//        self.passwordView.passwordTextField.rx.text
//            .map { $0?.trimmed }
//            .map { Reactor.Action.password($0) }
//            .bind(to: reactor.action)
//            .disposed(by: self.disposeBag)
        // state
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.navigationBar.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: self.rx.loading)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.isActivating }
            .distinctUntilChanged()
            .bind(to: self.rx.activating)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.error }
            .distinctUntilChanged({ $0?.asHiError == $1?.asHiError })
            .bind(to: self.rx.error)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.user }
            .distinctUntilChanged()
            .skip(1)
            .filterNil()
            .subscribeNext(weak: self, type(of: self).handleUser)
            .disposed(by: self.disposeBag)
//        Observable.combineLatest([
//            reactor.state.map { $0.phone }.replaceNilWith("").distinctUntilChanged(),
//            reactor.state.map { $0.captcha }.replaceNilWith("").distinctUntilChanged()
//        ])
//            .map { $0[0].isNotEmpty && $0[1].count == 5 }
//            .distinctUntilChanged()
//            .bind(to: self.loginButton.rx.isEnabled)
//            .disposed(by: self.disposeBag)
//        Observable.combineLatest([
//            reactor.state.map { $0.username }.replaceNilWith("").distinctUntilChanged(),
//            reactor.state.map { $0.password }.replaceNilWith("").distinctUntilChanged()
//        ])
//            .map { $0[0].count > 2 && $0[1].isNotEmpty }
//            .distinctUntilChanged()
//            .bind(to: self.loginButton.rx.isEnabled)
//            .disposed(by: self.disposeBag)
    }

    func handleUser(user: User) {
        log("login success")
        MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
            guard let `self` = self else { fatalError() }
            User.update(user, reactive: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.back(result: user)
            }
            return Disposables.create {}
        }.disposed(by: self.disposeBag)
    }
    
}
