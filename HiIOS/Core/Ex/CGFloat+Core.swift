//
//  CGFloat+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import QMUIKit

public extension CGFloat {
    
    var removeMin: CGFloat {
        QMUIKit.removeFloatMin(self)
    }
    
    var safed: CGFloat {
        QMUIKit.CGFloatSafeValue(self)
    }
    
    var ceil: CGFloat {
        Foundation.ceil(self.removeMin)
    }
    
    var floor: CGFloat {
        Foundation.floor(self.removeMin)
    }
    
    var flat: CGFloat {
        QMUIKit.flat(self)
    }
    
    var floorInPixel: CGFloat {
        QMUIKit.floorInPixel(self)
    }
    
    func fixed(_ precision: UInt) -> CGFloat {
        QMUIKit.CGFloatToFixed(self, precision)
    }

}


public extension IntegerLiteralType {
    var f: CGFloat {
        return CGFloat(self)
    }
}

public extension FloatLiteralType {
    var f: CGFloat {
        return CGFloat(self)
    }
}
