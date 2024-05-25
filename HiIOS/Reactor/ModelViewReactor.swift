//
//  ModelViewReactor.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/19.
//

import Foundation
import ObjectMapper
import HiCore
import HiDomain

open class ModelViewReactor: ReactorType, WithModel, CustomStringConvertible {

    public let model: any ModelType
    
    public required init(_ model: any ModelType) {
        self.model = model
    }
    
    open var description: String {
        self.model.description
    }

}
