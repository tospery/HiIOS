//
//  AttributedLabel.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/9.
//

import UIKit
import TTTAttributedLabel
import HiTheme

open class AttributedLabel: TTTAttributedLabel {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.theme.backgroundColor = themeService.attribute { $0.backgroundColor }
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
    
}
