//
//  CGRect+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import QMUIKit

public extension CGRect {
    
    init?(string: String) {
        var myString = string.removingPrefix("(")
        myString = myString.removingSuffix(")")
        let components = myString.components(separatedBy: ",")
        guard components.count == 4 else { return nil }
        guard let x = components[0].trimmed.double() else { return nil }
        guard let y = components[1].trimmed.double() else { return nil }
        guard let width = components[2].trimmed.double() else { return nil }
        guard let height = components[3].trimmed.double() else { return nil }
        self.init(x: x, y: y, width: width, height: height)
    }
    
    var minEdge: CGFloat {
        return min(width, height)
    }
    
    var maxEdge: CGFloat {
        return max(width, height)
    }
    
    var isNaN: Bool {
        QMUIKit.CGRectIsNaN(self)
    }

    var isInf: Bool {
        QMUIKit.CGRectIsInf(self)
    }

    var isValidated: Bool {
        QMUIKit.CGRectIsValidated(self)
    }

    var removeMin: CGRect {
        QMUIKit.CGRectRemoveFloatMin(self)
    }
            
    var safed: CGRect {
        QMUIKit.CGRectSafeValue(self)
    }
            
    var flat: CGRect {
        QMUIKit.CGRectFlatted(self)
    }

    func fixed(_ precision: UInt) -> CGRect {
        QMUIKit.CGRectToFixed(self, precision)
    }
    
    func rectBy(x: CGFloat) -> CGRect {
        QMUIKit.CGRectSetX(self, x)
    }
    
    func rectBy(y: CGFloat) -> CGRect {
        QMUIKit.CGRectSetY(self, y)
    }
    
    func rectBy(x: CGFloat, y: CGFloat) -> CGRect {
        QMUIKit.CGRectSetXY(self, x, y)
    }
    
    func rectBy(width: CGFloat) -> CGRect {
        QMUIKit.CGRectSetWidth(self, width)
    }
    
    func rectBy(height: CGFloat) -> CGRect {
        QMUIKit.CGRectSetHeight(self, height)
    }
    
    func rectBy(size: CGSize) -> CGRect {
        QMUIKit.CGRectSetSize(self, size)
    }

}
