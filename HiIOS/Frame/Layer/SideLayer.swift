//
//  SideLayer.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import UIKit

public typealias SideInsets = (CGFloat, CGFloat)

public struct SidePosition: OptionSet, Hashable {
    public var rawValue: UInt
    public var hashValue: Int

    public init(rawValue: UInt) {
        self.rawValue = rawValue
        self.hashValue = Int(rawValue)
    }

    public static let top    = SidePosition(rawValue: 1 << 0)
    public static let left   = SidePosition(rawValue: 1 << 1)
    public static let bottom = SidePosition(rawValue: 1 << 2)
    public static let right  = SidePosition(rawValue: 1 << 3)
    public static let shadow = SidePosition(rawValue: 1 << 4)
}

final public class SideLayer: CALayer {

    public var sidePositions: SidePosition = [] {
        didSet {
            self.updateSidesHidden()
        }
    }

    let topSide = CALayer()
    let leftSide = CALayer()
    let bottomSide = CALayer()
    let rightSide = CALayer()

    let shadowLayers = [CALayer(), CALayer(), CALayer()]

    public var sideColors = [SidePosition: UIColor]() {
        didSet {
            self.updateSidesColor()
        }
    }
    public var sideWidths = [SidePosition: CGFloat]() {
        didSet {
            self.updateSidesFrame()
        }
    }
    public var sideInsets = [SidePosition: SideInsets]() {
        didSet {
            self.updateSidesFrame()
        }
    }

    override public var frame: CGRect {
        didSet {
            self.updateSidesFrame()
        }
    }

    override init() {
        super.init()

        self.borderColor = nil
        self.borderWidth = 0

        self.addSublayer(self.topSide)
        self.addSublayer(self.leftSide)
        self.addSublayer(self.bottomSide)
        self.addSublayer(self.rightSide)
        for shadow in self.shadowLayers {
            self.addSublayer(shadow)
        }

        self.updateSidesHidden()
        self.updateSidesColor()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateSidesHidden() {
        self.topSide.isHidden = !self.sidePositions.contains(.top)
        self.leftSide.isHidden = !self.sidePositions.contains(.left)
        self.bottomSide.isHidden = !self.sidePositions.contains(.bottom)
        self.rightSide.isHidden = !self.sidePositions.contains(.right)

        let shadowHidden = !self.sidePositions.contains(.shadow)
        for shadowLayer in self.shadowLayers {
            shadowLayer.isHidden = shadowHidden
        }
    }

    func updateSidesColor() {
        self.topSide.backgroundColor = self.colorForSide(.top).cgColor
        self.leftSide.backgroundColor = self.colorForSide(.left).cgColor
        self.bottomSide.backgroundColor = self.colorForSide(.bottom).cgColor
        self.rightSide.backgroundColor = self.colorForSide(.right).cgColor

        let color = self.colorForSide(.shadow)
        for (i, shadow) in self.shadowLayers.enumerated() {
            let alpha = (CGFloat(self.shadowLayers.count - i) - 0.6) / CGFloat(self.shadowLayers.count)
            shadow.backgroundColor = color.withAlphaComponent(alpha).cgColor
        }
    }

    func updateSidesFrame() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        let topInsets = self.insetsForSide(.top)
        self.topSide.frame.size.width = self.frame.width - topInsets.0 - topInsets.1
        self.topSide.frame.size.height = self.widthForSide(.top)
        self.topSide.frame.origin.x = topInsets.0

        let bottomInsets = self.insetsForSide(.bottom)
        self.bottomSide.frame.size.width = self.frame.width - bottomInsets.0 - bottomInsets.1
        self.bottomSide.frame.size.height = self.widthForSide(.bottom)
        self.bottomSide.frame.origin.x = bottomInsets.0
        self.bottomSide.frame.origin.y = self.frame.height - self.bottomSide.frame.size.height

        let leftInsets = self.insetsForSide(.left)
        self.leftSide.frame.size.width = self.widthForSide(.left)
        self.leftSide.frame.size.height = self.frame.height - leftInsets.0 - leftInsets.1
        self.leftSide.frame.origin.y = leftInsets.0

        let rightInsets = self.insetsForSide(.right)
        self.rightSide.frame.size.width = self.widthForSide(.right)
        self.rightSide.frame.size.height = self.frame.height - rightInsets.0 - rightInsets.1
        self.rightSide.frame.origin.x = self.frame.width - self.rightSide.frame.size.width
        self.rightSide.frame.origin.y = rightInsets.0

        CATransaction.commit()
    }

    override public func layoutSublayers() {
        super.layoutSublayers()
        self.topSide.zPosition = CGFloat(self.sublayers?.count ?? 0)
        self.leftSide.zPosition = self.topSide.zPosition
        self.bottomSide.zPosition = self.topSide.zPosition
        self.rightSide.zPosition = self.topSide.zPosition

        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        for (i, shadow) in self.shadowLayers.enumerated() {
            shadow.frame.origin.y = self.frame.size.height + (i.f / UIScreen.main.scale)
            shadow.frame.size.width = self.bottomSide.frame.size.width
            shadow.frame.size.height = 1 / UIScreen.main.scale
        }

        CATransaction.commit()
    }


    // MARK: Utils
    func colorForSide(_ border: SidePosition) -> UIColor {
        if let value = self.sideColors[border] {
            return value
        }
        for (key, value) in self.sideColors {
            if key.contains(border) {
                return value
            }
        }
        return .lightGray
    }

    func widthForSide(_ border: SidePosition) -> CGFloat {
        if let value = self.sideWidths[border] {
            return value
        }
        for (key, value) in self.sideWidths {
            if key.contains(border) {
                return value
            }
        }
        return 0
    }

    func insetsForSide(_ border: SidePosition) -> SideInsets {
        if let value = self.sideInsets[border] {
            return value
        }
        for (key, value) in self.sideInsets {
            if key.contains(border) {
                return value
            }
        }
        return (0, 0)
    }
}

