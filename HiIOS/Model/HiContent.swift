//
//  HiContent.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/16.
//

import Foundation
import ObjectMapper
import HiCore
import HiDomain

public struct HiContent: Equatable {
    
    public let header: (any ModelType)?
    public let models: [any ModelType]
    
    public init(header: (any ModelType)?, models: [any ModelType]) {
        self.header = header
        self.models = models
    }
    
    public static func == (lhs: HiContent, rhs: HiContent) -> Bool {
        if !compareAny(lhs.header, rhs.header) {
            return false
        }
        return compareAny(lhs.models, rhs.models)
    }

}
