//
//  BoolTransform.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import ObjectMapper_Hi
import SwifterSwift_Hi

public class BoolTransform: TransformType {

    public typealias Object = Bool
    public typealias JSON = Any
    
    public init() {}
    
    public func transformFromJSON(_ value: Any?) -> Bool? {
        if let bool = value as? Bool {
            return bool
        } else if let int = value as? Int {
            return int.bool
        } else if let string = value as? String {
            return string.bool
        } else {
            return nil
        }
    }

    public func transformToJSON(_ value: Bool?) -> Any? {
        return value
    }
    
}
