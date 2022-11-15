//
//  ModelViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation

open class ModelViewReactor: ReactorType, WithModel, CustomStringConvertible {

    public let model: ModelType
    
    public required init(_ model: ModelType) {
        self.model = model
    }
    
    open var description: String {
        return self.model.description
    }
    
}
