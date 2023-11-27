//
//  List+Ex.swift
//  IOSTemplate
//
//  Created by liaoya on 2021/6/28.
//

import Foundation
import HiIOS
import ReusableKit_Hi
import ObjectMapper_Hi

extension List: ListCompatible {
    public func count(map: Map) -> Int {
        var count: Int?
        count   <- map["total_count"]
        return count ?? 0
    }
}
