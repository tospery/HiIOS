//
//  StringTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import ObjectMapper
import SwifterSwift

public class StringTransform: TransformType {

    public typealias Object = String
    public typealias JSON = Any
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> String? {
        if let bool = value as? Bool {
            return bool.string
        } else if let int = value as? Int {
            return int.string
        } else if let string = value as? String {
            return string
        } else {
            return (self as? CustomStringConvertible)?.description
        }
    }

    public func transformToJSON(_ value: String?) -> Any? {
        return value
    }
    
}
