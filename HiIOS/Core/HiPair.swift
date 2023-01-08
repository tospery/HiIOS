//
//  HiPair.swift
//  HiIOS
//
//  Created by 杨建祥 on 2023/1/9.
//

import Foundation

public struct HiPair: CustomStringConvertible {

    public let key: Any
    public let value: Any?
    
    public init(key: Any, value: Any?) {
        self.key = key
        self.value = value
    }
    
    public var description: String {
        var result = "\(self.key)"
        if self.value != nil {
            result += "(\(self.value!))"
        }
        return result
    }

}
