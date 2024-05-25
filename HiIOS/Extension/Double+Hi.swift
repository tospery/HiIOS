//
//  Double+Hi.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/3/26.
//

import Foundation

public extension Double {
    
    var decimalText: String {
        let format = NumberFormatter()
        format.numberStyle = .decimal
        return format.string(from: .init(value: self)) ?? self.string
    }
    
}
