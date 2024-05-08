//
//  TestView.swift
//  HiIOSDemo
//
//  Created by 杨建祥 on 2024/5/8.
//

import UIKit
import HiIOS

class TestView: UIView {
    
    override class var layerClass: AnyClass {
        BorderLayer.self
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.layer.frame.size = self.bounds.size
    }
    
}
