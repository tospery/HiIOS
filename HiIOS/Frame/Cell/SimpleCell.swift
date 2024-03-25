//
//  SimpleCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/3/21.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator_Hi

open class SimpleCell: BaseCollectionCell, ReactorKit.View {
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = .normal(Metric.Simple.titleFontSize)
        label.theme.textColor = themeService.attribute { $0.titleColor }
        label.sizeToFit()
        return label
    }()

    public lazy var detailLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = .normal(Metric.Simple.detailFontSize)
        label.textAlignment = .right
        label.theme.textColor = themeService.attribute { $0.bodyColor }
        label.sizeToFit()
        return label
    }()

    public lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.theme.tintColor = themeService.attribute { $0.primaryColor }
        imageView.sizeToFit()
        return imageView
    }()

    public lazy var indicatorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.indicator.template
        imageView.theme.tintColor = themeService.attribute { $0.primaryColor }
        imageView.sizeToFit()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderLayer?.borders = .bottom
        self.borderLayer?.borderColors = [BorderLayer.Border.bottom: UIColor.border]
        self.borderLayer?.borderWidths = [BorderLayer.Border.bottom: pixelOne]
        self.borderLayer?.borderInsets = [BorderLayer.Border.bottom: (15, 0)]
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.detailLabel)
        self.contentView.addSubview(self.iconImageView)
        self.contentView.addSubview(self.indicatorImageView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class var layerClass: AnyClass {
        return BorderLayer.self
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.layer.frame.size = self.bounds.size
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.detailLabel.text = nil
        self.iconImageView.image = nil
        self.indicatorImageView.isHidden = true
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if (self.model as? Simple)?.isButton ?? false {
            self.layoutButton()
            return
        }
        if self.iconImageView.isHidden || self.iconImageView.image == nil {
            self.iconImageView.frame = .zero
            self.iconImageView.left = 20
            self.iconImageView.top = self.iconImageView.topWhenCenter
        } else {
            self.iconImageView.sizeToFit()
            self.iconImageView.height = (self.contentView.height * 0.5).flat
            self.iconImageView.width = self.iconImageView.height
            self.iconImageView.top = self.iconImageView.topWhenCenter
            self.iconImageView.left = 20
            if self.reactor?.currentState.icon is URL {
                self.iconImageView.layerCornerRadius = self.iconImageView.height / 2.0
            } else {
                self.iconImageView.layerCornerRadius = 0
            }
        }
        
        self.indicatorImageView.sizeToFit()
        self.indicatorImageView.top = self.indicatorImageView.topWhenCenter
        self.indicatorImageView.right = self.contentView.width - 15
        
        self.titleLabel.sizeToFit()
        self.titleLabel.top = self.titleLabel.topWhenCenter
        if self.iconImageView.isHidden {
            self.titleLabel.left = self.iconImageView.left
        } else {
            self.titleLabel.left = self.iconImageView.right + 10
        }
        
        self.detailLabel.sizeToFit()
        self.detailLabel.top = self.detailLabel.topWhenCenter
        if self.indicatorImageView.isHidden {
            self.detailLabel.right = self.indicatorImageView.right
        } else {
            self.detailLabel.right = self.indicatorImageView.left - 8
        }
        
        if self.titleLabel.right > self.detailLabel.left {
            self.titleLabel.extendToRight = self.detailLabel.left - 2
        }
    }
    
    open func bind(reactor: SimpleItem) {
        super.bind(item: reactor)
        guard let simple = reactor.model as? Simple else { return }
        if simple.isSpace {
            self.bindSpace(reactor: reactor)
            return
        }
        if simple.isButton {
            self.bindButton(reactor: reactor)
            return
        }
        self.contentView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
        self.titleLabel.theme.textColor = themeService.attribute { $0.titleColor }
        reactor.state.map { $0.icon }
            .distinctUntilChanged { HiIOS.compareImage($0, $1) }
            .bind(to: self.iconImageView.rx.imageResource(alwaysTemplate: true))
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.detail }
            .distinctUntilChanged()
            .bind(to: self.detailLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { !$0.indicated }
            .distinctUntilChanged()
            .bind(to: self.indicatorImageView.rx.isHidden)
            .disposed(by: self.disposeBag)
        reactor.state.map { $0.divided }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] divided in
                guard let `self` = self else { return }
                self.borderLayer?.borderWidths = divided ? [BorderLayer.Border.bottom: pixelOne] : [:]
            })
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    open func bindSpace(reactor: SimpleItem) {
        self.contentView.theme.backgroundColor = themeService.attribute { _ in reactor.color ?? UIColor.clear }
        self.borderLayer?.borderWidths = [:]
        self.indicatorImageView.isHidden = true
    }
    
    open func bindButton(reactor: SimpleItem) {
        self.contentView.theme.backgroundColor = themeService.attribute { _ in reactor.color ?? UIColor.clear }
        self.borderLayer?.borderWidths = [:]
        self.indicatorImageView.isHidden = true
        self.titleLabel.font = .normal(17)
        self.titleLabel.theme.textColor = themeService.attribute { _ in reactor.tintColor ?? UIColor.primary }
        reactor.state.map { $0.title }
            .distinctUntilChanged()
            .bind(to: self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map { _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
    open func layoutButton() {
        self.titleLabel.textAlignment = .left
        self.titleLabel.sizeToFit()
        self.titleLabel.layerCornerRadius = 0
        self.titleLabel.left = self.titleLabel.leftWhenCenter
        self.titleLabel.top = self.titleLabel.topWhenCenter
    }
    
    open override class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        guard let simple = item.model as? Simple else { return .zero }
        return .init(
            width: width,
            height: simple.height ?? (
                simple.isSpace ? Metric.Simple.spaceHeight : simple.isButton ? Metric.Simple.buttonHeight : Metric.Simple.cellHeight
            )
        )
    }
    
}
