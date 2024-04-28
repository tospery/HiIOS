//
//  ModelViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation

open class ModelViewReactor: ReactorType, WithModel, CustomStringConvertible {

    public let model: any ModelType
    
    public required init(_ model: any ModelType) {
        self.model = model
    }
    
    open var description: String {
        return self.model.description
    }
    
//    public func hash(into hasher: inout Hasher) {
//        hasher.combine(self.model.hashValue)
//    }
//    
//    public static func == (lhs: ModelViewReactor, rhs: ModelViewReactor) -> Bool {
//        lhs.hashValue == rhs.hashValue
//    }
    
}
