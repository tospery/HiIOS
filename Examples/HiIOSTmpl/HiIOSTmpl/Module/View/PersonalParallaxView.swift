//
//  PersonalParallaxView.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/11.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import BonMot
import RxGesture
import SnapKit
import HiIOS

class PersonalParallaxView: UIImageView {
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.medium)
        view.sizeToFit()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.image = R.image.personal_parallax_bg()
        self.theme.backgroundColor = themeService.attribute { $0.lightColor }
        self.addSubview(self.activityIndicatorView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.activityIndicatorView.left = self.activityIndicatorView.leftWhenCenter
        self.activityIndicatorView.top = navigationContentTopConstant - 4
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        intrinsicContentSize
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: deviceWidth, height: Metric.Personal.parallaxAllHeight / standardWidth * deviceWidth)
    }
    
    func bind(reactor: PersonalViewReactor) {
        reactor.state.map { $0.isRefreshing }
            .distinctUntilChanged()
            .bind(to: self.rx.refreshing)
            .disposed(by: self.rx.disposeBag)
    }
    
}

extension Reactive where Base: PersonalParallaxView {
    
    var refreshing: Binder<Bool> {
        return Binder(self.base) { view, isRefreshing in
            if isRefreshing {
                view.activityIndicatorView.startAnimating()
            } else {
                MainScheduler.asyncInstance.scheduleRelative((), dueTime: .seconds(1)) { _ in
                    view.activityIndicatorView.stopAnimating()
                    return Disposables.create {}
                }.disposed(by: self.disposeBag)
            }
        }
    }
    
//    var tapUser: ControlEvent<Void> {
//        let source = base.infoView.rx.tapGesture().when(.recognized).map { _ in }
//        return ControlEvent(events: source)
//    }
    
}
