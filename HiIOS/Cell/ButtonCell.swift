//
//  ButtonCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/5.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi
import HiCore

import HiTheme
import HiNav

open class ButtonCell: BaseCollectionCell, ReactorKit.View {
    
    struct Metric {
        static let height = 50.f
    }
    
    lazy var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.titleLabel?.font = .normal(17)
        button.sizeToFit()
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.button)
        self.contentView.theme.backgroundColor = themeService.attribute { $0.lightColor }
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        let style = self.reactor?.style ?? .plain
        if style == .plain {
            self.layoutPlain()
        } else if style == .round {
            self.layoutRound()
        }
    }

    open func bind(reactor: ButtonItem) {
        super.bind(item: reactor)
        let style = reactor.style
        if style == .plain {
            self.bindPlain()
        } else if style == .round {
            self.bindRound()
        }
        reactor.state.map { $0.enabled ?? false }
            .distinctUntilChanged()
            .bind(to: self.rx.enable)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.button.rx.titleForNormal)
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    func layoutPlain() {
        self.button.layerCornerRadius = 0
        self.button.sizeToFit()
        self.button.width = self.contentView.width
        self.button.height = self.contentView.height
        self.button.left = self.button.leftWhenCenter
        self.button.top = self.button.topWhenCenter
    }
    
    func layoutRound() {
        self.button.layerCornerRadius = 8
        self.button.sizeToFit()
        self.button.width = self.contentView.width - 20 * 2
        self.button.height = self.contentView.height * 0.84
        self.button.left = self.button.leftWhenCenter
        self.button.top = self.button.topWhenCenter
    }
    
    func bindPlain() {
        self.button.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
        self.button.theme.titleColor(
            from: themeService.attribute { $0.primaryColor },
            for: .normal
        )
    }
    
    func bindRound() {
        self.button.theme.titleColor(
            from: themeService.attribute { $0.backgroundColor },
            for: .normal
        )
        self.button.theme.backgroundImage(
            from: themeService.attribute {
                UIImage.init(
                    color: $0.primaryColor,
                    size: .init(width: deviceWidth, height: Metric.height)
                )
            },
            for: .normal
        )
        self.button.theme.backgroundImage(
            from: themeService.attribute {
                UIImage.init(
                    color: $0.primaryColor.withAlphaComponent(0.7),
                    size: .init(width: deviceWidth, height: Metric.height)
                )
            },
            for: .disabled
        )
    }
    
    open override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        .init(width: width, height: Metric.height)
    }

}

public extension Reactive where Base: ButtonCell {
    
    var enable: Binder<Bool> {
        self.base.button.rx.isEnabled
    }

    var click: Observable<String?> {
        self.base.button.rx.tap.map { [weak base] _ -> String? in
            guard let strongBase = base else { return nil }
            return (strongBase.model as? ButtonInfo)?.target
        }
    }
    
}
