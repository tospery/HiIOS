//
//  PortalCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import ReactorKit

open class PortalCell: BaseCollectionCell, ReactorKit.View {
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = .normal(16)
        label.theme.textColor = themeService.attribute { $0.titleColor }
        label.sizeToFit()
        return label
    }()

    public lazy var detailLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.font = .normal(14)
        label.textAlignment = .right
        label.theme.textColor = themeService.attribute { $0.headerColor }
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
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.borderLayer?.borders = .bottom
        self.borderLayer?.borderColors = [BorderLayer.Border.bottom: UIColor.separator]
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
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.indicatorImageView.sizeToFit()
        self.indicatorImageView.top = self.indicatorImageView.topWhenCenter
        self.indicatorImageView.right = self.contentView.width - 15
        
        self.titleLabel.sizeToFit()
        self.titleLabel.left = 15
        self.titleLabel.top = self.titleLabel.topWhenCenter
        
        self.detailLabel.sizeToFit()
        self.detailLabel.top = self.detailLabel.topWhenCenter
        if self.indicatorImageView.isHidden {
            self.detailLabel.right = self.indicatorImageView.right
        } else {
            self.detailLabel.right = self.indicatorImageView.left - 8
        }
        
        if self.iconImageView.isHidden {
            self.iconImageView.frame = .zero
        } else {
            self.iconImageView.sizeToFit()
            self.iconImageView.height = (self.contentView.height * 0.6).flat
            self.iconImageView.width = self.iconImageView.height
            self.iconImageView.top = self.iconImageView.topWhenCenter
            self.iconImageView.right = self.detailLabel.left - 8
            self.iconImageView.layerCornerRadius = self.iconImageView.height / 2.0
        }
    }
    
    public func bind(reactor: PortalItem) {
        super.bind(item: reactor)
        reactor.state.map{ !$0.indicated }
            .bind(to: self.indicatorImageView.rx.isHidden)
            .disposed(by: self.disposeBag)
        reactor.state.map{ $0.title }
            .bind(to: self.titleLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map{ $0.detail }
            .bind(to: self.detailLabel.rx.text)
            .disposed(by: self.disposeBag)
        reactor.state.map{ $0.icon }
            .bind(to: self.iconImageView.rx.imageSource)
            .disposed(by: self.disposeBag)
        reactor.state.map{ _ in }
            .bind(to: self.rx.setNeedsLayout)
            .disposed(by: self.disposeBag)
    }
    
}
