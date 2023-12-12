//
//  RepoCell.swift
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
import RxGesture
import TTTAttributedLabel
import HiIOS

class RepoCell: BaseCollectionCell, ReactorKit.View {

    let clickSubject = PublishSubject<String>()
    
    lazy var nameLabel: TTTAttributedLabel = {
        let label = TTTAttributedLabel.init(frame: .zero)
        label.delegate = self
        label.verticalAlignment = .center
        label.numberOfLines = 2
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
    
    lazy var langLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        return label
    }()
    
    lazy var starsLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        return label
    }()
    
    lazy var forksLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        return label
    }()
    
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView.init()
        imageView.sizeToFit()
        imageView.layerCornerRadius = 4
        imageView.size = HiIOSTmpl.Metric.BasicCell.avatarSize
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.qmui_borderWidth = pixelOne
        self.contentView.qmui_borderPosition = .bottom
        self.contentView.qmui_borderInsets = .init(top: 0, left: 0, bottom: 0, right: 10)
        self.contentView.theme.qmui_borderColor = themeService.attribute { $0.borderColor }
        self.contentView.addSubview(self.nameLabel)
        self.contentView.addSubview(self.avatarImageView)
        self.contentView.addSubview(self.langLabel)
        self.contentView.addSubview(self.starsLabel)
        self.contentView.addSubview(self.forksLabel)
        self.contentView.addSubview(self.descLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarImageView.left = HiIOSTmpl.Metric.BasicCell.margin.left
        self.avatarImageView.top = HiIOSTmpl.Metric.BasicCell.margin.top
        self.langLabel.sizeToFit()
        self.langLabel.left = self.avatarImageView.right + HiIOSTmpl.Metric.BasicCell.padding.horizontal
        self.langLabel.bottom = self.avatarImageView.bottom - 2
        self.forksLabel.sizeToFit()
        self.forksLabel.width = HiIOSTmpl.Metric.BasicCell.forksWidth
        self.forksLabel.right = self.contentView.width
        self.forksLabel.centerY = self.langLabel.centerY
        self.starsLabel.sizeToFit()
        self.starsLabel.left = self.langLabel.left + (self.contentView.width - self.nameLabel.left) * 0.4
        self.starsLabel.centerY = self.langLabel.centerY
        self.nameLabel.sizeToFit()
        self.nameLabel.left = self.langLabel.left
        self.nameLabel.top = 0
        self.nameLabel.extendToRight = self.contentView.width - HiIOSTmpl.Metric.BasicCell.margin.right
        self.nameLabel.extendToBottom = self.langLabel.top
        self.descLabel.sizeToFit()
        self.descLabel.left = self.avatarImageView.left
        self.descLabel.top = self.avatarImageView.bottom
        self.descLabel.extendToRight = self.contentView.width - HiIOSTmpl.Metric.BasicCell.margin.right
        self.descLabel.extendToBottom = self.contentView.height
    }

    func bind(reactor: RepoItem) {
        super.bind(item: reactor)
        reactor.state.map { $0.name }
            .distinctUntilChanged()
            .bind(to: self.rx.name)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.desc }
            .distinctUntilChanged()
            .bind(to: self.descLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.lang }
            .distinctUntilChanged()
            .bind(to: self.langLabel.rx.attributedText)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.stars }
            .distinctUntilChanged()
            .bind(to: self.starsLabel.rx.attributedText)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.forks }
            .distinctUntilChanged()
            .bind(to: self.forksLabel.rx.attributedText)
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

extension RepoCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith result: NSTextCheckingResult!) {
        guard result.range.location == 0 else { return }
        guard let username = (self.model as? Repo)?.owner.username else { return }
        self.clickSubject.onNext(username)
    }
}

extension Reactive where Base: RepoCell {
    
    var clickUser: ControlEvent<String> {
        let source = self.base.clickSubject
        return ControlEvent(events: source)
    }
    
    var name: Binder<NSAttributedString?> {
        return Binder(self.base) { cell, name in
            cell.nameLabel.setText(name)
            if let string = name?.string {
                let array = string.components(separatedBy: " / ")
                if array.count == 2 {
                    let length = array.first?.count ?? 0
                    cell.nameLabel.addLink(.init(
                        attributes: [
                            NSAttributedString.Key.foregroundColor: UIColor.primary,
                            NSAttributedString.Key.font: UIFont.bold(16)
                        ],
                        activeAttributes: [
                            NSAttributedString.Key.foregroundColor: UIColor.red
                        ],
                        inactiveAttributes: [
                            NSAttributedString.Key.foregroundColor: UIColor.gray
                        ],
                        textCheckingResult: .spellCheckingResult(range: .init(location: 0, length: length))
                    ))
                }
            }
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
        }
    }
    
}
