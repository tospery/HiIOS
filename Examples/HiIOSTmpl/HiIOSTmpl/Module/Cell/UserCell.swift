//
//  UserCell.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/13.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import RxGesture
import RswiftResources
import HiIOS

class UserCell: BaseCollectionCell, ReactorKit.View {

    lazy var userLabel: UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 2
        label.font = .bold(16)
        label.theme.textColor = themeService.attribute { $0.foregroundColor }
        label.sizeToFit()
        return label
    }()
    
    lazy var repoLabel: UILabel = {
        let label = UILabel.init()
        label.isUserInteractionEnabled = true
        label.sizeToFit()
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel.init()
        label.font = .normal(15)
        label.numberOfLines = 2
        label.theme.textColor = themeService.attribute { $0.titleColor }
        label.sizeToFit()
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layerCornerRadius = 4
        imageView.sizeToFit()
        imageView.size = HiIOSTmpl.Metric.BasicCell.avatarSize
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.qmui_borderWidth = pixelOne
        self.contentView.qmui_borderPosition = .bottom
        self.contentView.qmui_borderInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        self.contentView.theme.qmui_borderColor = themeService.attribute { $0.borderColor }
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.userLabel)
        self.contentView.addSubview(self.descLabel)
        self.contentView.addSubview(self.repoLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.left = HiIOSTmpl.Metric.BasicCell.margin.left
        self.avatarImageView.top = HiIOSTmpl.Metric.BasicCell.margin.top
        self.userLabel.sizeToFit()
        self.userLabel.left = self.avatarImageView.right + HiIOSTmpl.Metric.BasicCell.padding.horizontal
        self.userLabel.top = self.avatarImageView.top
        self.userLabel.extendToRight = self.contentView.width - HiIOSTmpl.Metric.BasicCell.margin.right
        self.repoLabel.sizeToFit()
        self.repoLabel.width = self.userLabel.width
        self.repoLabel.left = self.userLabel.left
        self.repoLabel.bottom = self.avatarImageView.bottom
        self.descLabel.width = self.contentView.width - HiIOSTmpl.Metric.BasicCell.margin.horizontal
        self.descLabel.left = self.avatarImageView.left
        self.descLabel.top = self.avatarImageView.bottom
        self.descLabel.extendToBottom = self.contentView.height
    }

    func bind(reactor: UserItem) {
        super.bind(item: reactor)
        reactor.state.map { $0.user }
            .distinctUntilChanged()
            .bind(to: self.userLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.repo }
            .distinctUntilChanged()
            .bind(to: self.repoLabel.rx.attributedText)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.desc }
            .distinctUntilChanged()
            .bind(to: self.descLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.avatar }
            .distinctUntilChanged { HiIOS.compareImage($0, $1) }
            .bind(to: self.avatarImageView.rx.imageResource(placeholder: R.image.ic_user_default()))
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        .init(width: width, height: HiIOSTmpl.Metric.BasicCell.height)
    }

}

extension Reactive where Base: UserCell {
    
    var clickRepo: ControlEvent<String> {
        let url = (base.model as? User)?.repo?.url ?? ""
        let source = base.repoLabel.rx.tapGesture().when(.recognized).map { _ in url }
        return ControlEvent(events: source)
    }
    
}
