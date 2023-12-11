//
//  AppInfoCell.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/10.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import RxGesture
import HiIOS

class AppInfoCell: BaseCollectionCell, ReactorKit.View {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = .normal(15)
        label.text = "v\(UIApplication.shared.version!)(\(UIApplication.shared.buildNumber!))"
        label.theme.textColor = themeService.attribute { $0.bodyColor }
        label.sizeToFit()
        return label
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = true
        imageView.image = R.image.appLogo()
        imageView.sizeToFit()
        imageView.size = .init(deviceWidth * 0.24)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.imageView)
        self.contentView.theme.backgroundColor = themeService.attribute { $0.lightColor }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView.left = self.imageView.leftWhenCenter
        self.imageView.top = (self.imageView.topWhenCenter * 0.9).flat
        self.titleLabel.left = self.titleLabel.leftWhenCenter
        self.titleLabel.top = self.imageView.bottom + 8
    }

    func bind(reactor: AppInfoItem) {
        super.bind(item: reactor)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        .init(width: width, height: 190)
    }

}

extension Reactive where Base: AppInfoCell {
    
    var tapLogo: ControlEvent<Void> {
        let source = base.imageView.rx.tapGesture().when(.recognized).map { _ in }
        return ControlEvent(events: source)
    }
    
}
