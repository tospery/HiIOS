//
//  ModelType.swift
//  HiIOS
//
//  Created by 杨建祥 on 2022/7/18.
//

import Foundation
import ObjectMapper
import RealmSwift
import SwifterSwift

public typealias JSONMap = ObjectMapper.Map

// MARK: - 模型协议
public protocol ModelType: Mappable, Identifiable, Hashable, CustomStringConvertible {
    var isValid: Bool { get }
    init()
}

public extension ModelType {

    var isValid: Bool { self.id.hashValue != 0 }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    var description: String {
        self.toJSONString() ?? self.id.hashValue.string
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

public protocol UserType: ModelType {
    var userid: String? { get }
    var username: String? { get }
    var nickname: String? { get }
    var password: String? { get }
    var avatar: String? { get }
}

public struct WrappedModel: ModelType {

    public var id = 0
    public var data: Any?
    
    public var isValid: Bool { self.data != nil }
    
    public init() {
    }
    
    public init(_ data: Any? = nil) {
        self.data = data
    }
    
    public init?(map: JSONMap) {
    }
    
    public mutating func mapping(map: JSONMap) {
        data    <- map["data"]
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description == rhs.description
    }
    
    public var description: String {
        String.init(describing: self.data)
    }

}

public struct ModelContext: MapContext {
    
    public let shouldMap: Bool
    
    public init(shouldMap: Bool = true){
        self.shouldMap = shouldMap
    }

}

