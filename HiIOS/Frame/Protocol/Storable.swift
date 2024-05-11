//
//  Storable.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/12.
//

import Foundation

// MARK: - 存储协议
public protocol Storable: ModelType, Codable {

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
