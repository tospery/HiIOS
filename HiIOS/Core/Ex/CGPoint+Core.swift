//
//  CGPoint+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import QMUIKit

public extension CGPoint {
    
    var removeMin: CGPoint {
        QMUIKit.CGPointRemoveFloatMin(self)
    }
        
    func fixed(_ precision: UInt) -> CGPoint {
        QMUIKit.CGPointToFixed(self, precision)
    }
    
}

