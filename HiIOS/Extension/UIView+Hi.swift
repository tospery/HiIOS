//
//  UIView+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import UIKit
import RxSwift
import RxCocoa

public enum ShadowPattern {
    case top, bottom, left, right, around, common
}

public extension UIView {
    
    fileprivate var borderLayer: BorderLayer? {
        return self.layer as? BorderLayer
    }
    
    var borders: BorderPosition? {
        get {
            self.borderLayer?.borders
        }
        set {
            self.borderLayer?.borders = newValue ?? []
        }
    }
    
    var borderColors: [BorderPosition: UIColor]? {
        get {
            self.borderLayer?.borderColors
        }
        set {
            self.borderLayer?.borderColors = newValue ?? [:]
        }
    }
    
    var borderWidths: [BorderPosition: CGFloat]? {
        get {
            self.borderLayer?.borderWidths
        }
        set {
            self.borderLayer?.borderWidths = newValue ?? [:]
        }
    }
    
    var borderInsets: [BorderPosition: BorderInsets]? {
        get {
            self.borderLayer?.borderInsets
        }
        set {
            self.borderLayer?.borderInsets = newValue ?? [:]
        }
    }
    
    var top: CGFloat {
        get {
            self.frame.minY
        }
        set {
            self.frame = self.frame.rectBy(y: newValue)
        }
    }
    
    var bottom: CGFloat {
        get {
            self.frame.maxY
        }
        set {
            self.frame = self.frame.rectBy(y: newValue - self.frame.height)
        }
    }
    
    var left: CGFloat {
        get {
            self.frame.minX
        }
        set {
            self.frame = self.frame.rectBy(x: newValue)
        }
    }
    
    var right: CGFloat {
        get {
            self.frame.maxX
        }
        set {
            self.frame = self.frame.rectBy(x: newValue - self.frame.width)
        }
    }
    
    var extendToTop: CGFloat {
        get {
            self.top
        }
        set {
            self.height = self.bottom - newValue
            self.top = newValue
        }
    }
    
    var extendToBottom: CGFloat {
        get {
            self.bottom
        }
        set {
            self.height = newValue - self.top
            self.bottom = newValue
        }
    }
    
    var extendToLeft: CGFloat {
        get {
            self.left
        }
        set {
            self.width = self.right - newValue
            self.left = newValue
        }
    }
    
    var extendToRight: CGFloat {
        get {
            self.right
        }
        set {
            self.width = newValue - self.left
            self.right = newValue
        }
    }
    
    var leftWhenCenter: CGFloat {
        (((self.superview?.bounds.width ?? 0) - self.frame.width) / 2.0).flat
    }
    
    var topWhenCenter: CGFloat {
        (((self.superview?.bounds.height ?? 0) - self.frame.height) / 2.0).flat
    }

    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }

    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    func addShadow(
        color: UIColor,
        opacity: CGFloat,
        radius: CGFloat,
        path: CGFloat,
        pattern: ShadowPattern
    ) {
        self.layer.masksToBounds = false // 必须要等于false否则会把阴影切割隐藏掉
        self.layer.shadowColor = color.cgColor // 阴影颜色
        self.layer.shadowOpacity = opacity.float // 阴影透明度，默认0
        self.layer.shadowOffset = .zero // 阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
        self.layer.shadowRadius = radius // 阴影半径，默认3
        
        let x = 0.f, y = 0.f
        let width = self.bounds.size.width, height = self.bounds.size.height
        
        var rect = CGRect.init()
        switch pattern {
        case .top:
            rect = .init(x: x, y: x - path / 2, width: width, height: path)
        case .bottom:
            rect = .init(x: y, y: height - path / 2, width: width, height: path)
        case .left:
            rect = .init(x: x - path / 2, y: y, width: path, height: height)
        case .right:
            rect = .init(x: width - path / 2, y: y, width: path, height: height)
        case .around:
            rect = .init(x: x - path / 2, y: y - path / 2, width: width + path, height: height + path)
        case .common:
            rect = .init(x: x - path / 2, y: 2, width: width + path, height: height + path / 2)
        }
        self.layer.shadowPath = UIBezierPath.init(rect: rect).cgPath // 阴影路径
    }
    
    func constrainCentered(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        let verticalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1.0,
            constant: 0
        )

        let horizontalContraint = NSLayoutConstraint(
            item: subview,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1.0,
            constant: 0
        )

        let heightContraint = NSLayoutConstraint(
            item: subview,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.height
        )

        let widthContraint = NSLayoutConstraint(
            item: subview,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: subview.frame.width
        )

        addConstraints([
            horizontalContraint,
            verticalContraint,
            heightContraint,
            widthContraint,
        ])
    }

    func constrainToEdges(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false

        let topContraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0
        )

        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        )

        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0
        )

        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0
        )

        addConstraints([
            topContraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint,
        ])
    }
    
    func startRotating() {
        if self.layer.animation(forKey: "hi.rotationAnimation") != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Double.pi / 2), 0.0, 0.0, 1.0))
        animation.duration = 0.25
        animation.repeatCount = .infinity
        animation.isCumulative = true
        animation.isRemovedOnCompletion = false
        self.layer.add(animation, forKey: "hi.rotationAnimation")
    }
    
    func stopRotating() {
        self.layer.removeAnimation(forKey: "hi.rotationAnimation")
    }
    
}

