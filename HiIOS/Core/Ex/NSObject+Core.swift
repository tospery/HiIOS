//
//  NSObject+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public extension NSObject {
    
    static var className: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
    
}
