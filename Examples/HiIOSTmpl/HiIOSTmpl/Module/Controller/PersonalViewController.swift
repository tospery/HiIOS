//
//  PersonalViewController.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
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
import MXParallaxHeader
import HiIOS

class PersonalViewController: ListViewController {
    
    lazy var parallaxView: PersonalParallaxView = {
        let parallaxView = PersonalParallaxView.init(frame: .zero)
        parallaxView.translatesAutoresizingMaskIntoConstraints = false
        parallaxView.sizeToFit()
//        parallaxView.rx.tapUser
//            .subscribeNext(weak: self, type(of: self).tapUser)
//            .disposed(by: self.rx.disposeBag)
//        parallaxView.rx.tapRepositories
//            .subscribeNext(weak: self, type(of: self).tapRepositories)
//            .disposed(by: self.rx.disposeBag)
//        parallaxView.rx.tapFollower
//            .subscribeNext(weak: self, type(of: self).tapFollower)
//            .disposed(by: self.rx.disposeBag)
//        parallaxView.rx.tapFollowing
//            .subscribeNext(weak: self, type(of: self).tapFollowing)
//            .disposed(by: self.rx.disposeBag)
        return parallaxView
    }()
    
    required init(_ navigator: NavigatorProtocol, _ reactor: BaseViewReactor) {
        super.init(navigator, reactor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.parallaxHeader.view = self.parallaxView
        self.collectionView.parallaxHeader.height = self.parallaxView.height
        self.collectionView.parallaxHeader.minimumHeight = self.parallaxView.height
        self.collectionView.parallaxHeader.mode = .topFill
        self.parallaxView.widthAnchor.constraint(equalTo: self.collectionView.widthAnchor).isActive = true
        self.navigationBar.theme.titleColor = themeService.attribute { $0.backgroundColor }
        self.collectionView.rx.didEndDragging
            .subscribeNext(weak: self, type(of: self).didEndDragging)
            .disposed(by: self.disposeBag)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarService.value.reversed
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func bind(reactor: ListViewReactor) {
        super.bind(reactor: reactor)
        // swiftlint:disable:next force_cast
        self.parallaxView.bind(reactor: reactor as! PersonalViewReactor)
    }
    
    func tapUser(_: Void? = nil) {
        if self.reactor?.currentState.user?.isValid ?? false {
            self.navigator.forward(Router.shared.urlString(host: .profile))
            return
        }
        self.navigator.login()
    }
    
    func tapTheme(_: Void? = nil) {
        log("tapTheme")
    }
    
    func tapRepositories(_: Void? = nil) {
//        if !(self.reactor?.currentState.user?.isValid ?? false) {
//            self.navigator.login()
//            return
//        }
//        guard let username = self.reactor?.currentState.user?.username else { return }
//        self.navigator.forward(
//            Router.shared.urlString(host: .page, parameters: [
//                Parameter.pages: Page.userValues.map { $0.rawValue }.jsonString() ?? "",
//                Parameter.index: Page.userValues.firstIndex(of: .repositories)?.string ?? "",
//                Parameter.username: username
//            ])
//        )
    }
    
    func tapFollower(_: Void? = nil) {
//        if !(self.reactor?.currentState.user?.isValid ?? false) {
//            self.navigator.login()
//            return
//        }
//        guard let username = self.reactor?.currentState.user?.username else { return }
//        self.navigator.forward(
//            Router.shared.urlString(host: .page, parameters: [
//                Parameter.pages: Page.userValues.map { $0.rawValue }.jsonString() ?? "",
//                Parameter.index: Page.userValues.firstIndex(of: .followers)?.string ?? "",
//                Parameter.username: username
//            ])
//        )
//        self.navigator.rxForward(Router.shared.urlString(host: .test))
//            .subscribe(onNext: { result in
//                log("test->next: \(result)")
//            }, onCompleted: {
//                log("test->complete")
//            })
//            .disposed(by: self.disposeBag)
    }
    
    func tapFollowing(_: Void? = nil) {
//        if !(self.reactor?.currentState.user?.isValid ?? false) {
//            self.navigator.login()
//            return
//        }
//        guard let username = self.reactor?.currentState.user?.username else { return }
//        self.navigator.forward(
//            Router.shared.urlString(host: .page, parameters: [
//                Parameter.pages: Page.userValues.map { $0.rawValue }.jsonString() ?? "",
//                Parameter.index: Page.userValues.firstIndex(of: .following)?.string ?? "",
//                Parameter.username: username
//            ])
//        )
    }
    
    func didEndDragging(isEnd: Bool) {
        let triggerOffset = Metric.Personal.parallaxAllHeight / standardWidth * deviceWidth + 50
        guard self.scrollView.contentOffset.y < triggerOffset * -1 else { return }
        MainScheduler.asyncInstance.schedule(()) { [weak self] _ -> Disposable in
            guard let `self` = self else { fatalError() }
            self.reactor?.action.onNext(.refresh)
            return Disposables.create {}
        }.disposed(by: self.disposeBag)
    }

}
