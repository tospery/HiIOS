//
//  Storable.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/12.
//

import Foundation
import ObjectMapper
import HiCore
import HiDomain

// MARK: - 存储协议
public protocol Storable: ModelType {

    // associatedtype Base: Storable where Base.Base == Base
    // associatedtype Store: Storable

    static func objectKey(id: String?) -> String
    static func arrayKey(page: String?) -> String

    static func storeObject(_ object: Self?, id: String?)
    static func storeArray(_ array: [Self]?, page: String?)

    static func cachedObject(id: String?) -> Self?
    static func cachedArray(page: String?) -> [Self]?

    static func eraseObject(id: String?)
}

public extension Storable {

    static func objectKey(id: String? = nil) -> String {
        var key = String(fullname: self)
        if let path = id {
            key += "#\(path)"
        }
        return key
    }

    static func arrayKey(page: String? = nil) -> String {
        var key = "\(String(fullname: self))List"
        if let path = page {
            key += "#\(path)"
        }
        return key
    }
    
    static func storeObject(_ object: Self?, id: String? = nil) {
    }

    static func storeArray(_ array: [Self]?, page: String? = nil) {
    }

    static func cachedObject(id: String? = nil) -> Self? {
        nil
    }

    static func cachedArray(page: String? = nil) -> [Self]? {
        nil
    }

    static func eraseObject(id: String? = nil) {
    }

}
