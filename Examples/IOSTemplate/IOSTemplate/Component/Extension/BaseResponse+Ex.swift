//
//  BaseResponse+Ex.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import Moya
import ObjectMapper_Hi
import HiIOS

extension BaseResponse: ResponseCompatible {
    
    public func code(map: Map) -> Int {
        var code: Int?
        code        <- map["code"]
        if code == nil {
            code = -1
        }
        return code == 0 ? ErrorCode.ok : code!
    }
    
    public func message(map: Map) -> String? {
        var message: String?
        message         <- map["msg"]
        return message
    }
    
    public func data(map: Map) -> Any? {
        var data: Any?
        data        <- map["data"]
        return data
    }
    
    public func code(_ target: TargetType) -> Int {
        return self.code
    }
    
    public func message(_ target: TargetType) -> String? {
        return self.message
    }
    
    public func data(_ target: TargetType) -> Any? {
        return self.data
    }

}
