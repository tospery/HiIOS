//
//  BaseCollectionCell.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import HiCore
import HiDomain
import HiTheme
import HiNav

open class BaseCollectionCell: UICollectionViewCell {
    
    public var disposeBag = DisposeBag()
    public var model: (any ModelType)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    open override class var layerClass: AnyClass {
        return BorderLayer.self
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.layer.frame.size = self.bounds.size
    }
    
    // MARK: - Public
    open func bind(item: BaseCollectionItem) {
        self.model = item.model
    }
    
    open class func size(width: CGFloat, item: BaseCollectionItem) -> CGSize {
        return CGSize(width: width, height: metric(44))
    }
    
    open class func size(height: CGFloat, item: BaseCollectionItem) -> CGSize {
        return CGSize(width: metric(100), height: height)
    }
    
}
