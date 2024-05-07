//
//  CGPoint+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public extension CGPoint {
    
    var removeMin: CGPoint {
        .init(x: self.x.removeMin, y: self.y.removeMin)
    }
        
    func fixed(_ precision: UInt) -> CGPoint {
        .init(x: self.x.fixed(precision), y: self.y.fixed(precision))
    }
    
}
