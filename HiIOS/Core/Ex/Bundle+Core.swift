//
//  Bundle+Core.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation

public extension Bundle {
    
    convenience init?(module: String) {
        self.init(identifier: "org.cocoapods." + module)
    }
    
}
