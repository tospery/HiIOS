//
//  IntTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import ObjectMapper_Hi
import SwifterSwift

public class IntTransform: TransformType {

    public typealias Object = Int
    public typealias JSON = Any
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Int? {
        if let bool = value as? Bool {
            return bool.int
        } else if let int = value as? Int {
            return int
        } else if let string = value as? String {
            return string.int
        } else {
            return nil
        }
    }

    public func transformToJSON(_ value: Int?) -> Any? {
        return value
    }
    
}
