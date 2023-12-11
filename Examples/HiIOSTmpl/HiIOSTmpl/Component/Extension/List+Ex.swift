//
//  List+Ex.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import ReusableKit
import ObjectMapper_Hi
import HiIOS

extension List: ListCompatible {
    public func hasNext(map: Map) -> Bool {
        var hasNext: Bool?
        hasNext   <- map["incomplete_results"]
        return !(hasNext ?? false)
    }
    
    public func count(map: Map) -> Int {
        var count: Int?
        count   <- map["total_count"]
        return count ?? 0
    }
    
    public func items<ListItem>(map: Map) -> [ListItem] where ListItem: ModelType {
        var items: [ListItem]?
        items    <- map["items"]
        return items ?? []
    }
}
