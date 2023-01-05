//
//  Storable.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import Cache

let archiver = try! Storage<String, String>.init(
    diskConfig: DiskConfig.init(name: "shared"),
    memoryConfig: MemoryConfig.init(),
    transformer: TransformerFactory.forCodable(ofType: String.self)
)

// MARK: - 存储协议
public protocol Storable: ModelType, Identifiable, Codable, Equatable {

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
        let key = self.objectKey(id: id)
        if let object = object {
            try? archiver.transformCodable(ofType: self).setObject(object, forKey: key)
        } else {
            try? archiver.removeObject(forKey: key)
        }
    }

    static func storeArray(_ array: [Self]?, page: String? = nil) {
        let key = self.arrayKey(page: page)
        if let array = array {
            try? archiver.transformCodable(ofType: [Self].self).setObject(array, forKey: key)
        } else {
            try? archiver.removeObject(forKey: key)
        }
    }

    static func cachedObject(id: String? = nil) -> Self? {
        let key = self.objectKey(id: id)
        if let object = try? archiver.transformCodable(ofType: self).object(forKey: key) {
            return object
        }
        if let path = Bundle.main.path(forResource: key, ofType: "json"),
            let json = try? String(contentsOfFile: path, encoding: .utf8) {
            return Self(JSONString: json)
        }
        return nil
    }

    static func cachedArray(page: String? = nil) -> [Self]? {
        let key = self.arrayKey(page: page)
        if let array = try? archiver.transformCodable(ofType: [Self].self).object(forKey: key) {
            return array
        }
        if let path = Bundle.main.path(forResource: key, ofType: "json"),
            let json = try? String(contentsOfFile: path, encoding: .utf8) {
            return [Self](JSONString: json)
        }
        return nil
    }

    static func eraseObject(id: String? = nil) {
        let key = self.objectKey(id: id)
        try? archiver.removeObject(forKey: key)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.description.sorted() == rhs.description.sorted()
    }

}

