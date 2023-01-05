//
//  HiSection.swift
//  HiIOS
//
//  Created by 杨建祥 on 2023/1/5.
//

import Foundation

public struct HiSection: CustomStringConvertible {

    public let header: ModelType?
    public let models: [ModelType]
    
    public init(header: ModelType?, models: [ModelType]) {
        self.header = header
        self.models = models
    }
    
    public var description: String {
        var result = header?.description ?? ""
        result += "("
        for model in models {
            result += model.description
        }
        result += ")"
        // print("HiSection的description: \(result)")
        return result
    }

}
