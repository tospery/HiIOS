//
//  Storable.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import Cache
import ObjectMapper
import RealmSwift

public let archiver = try! Storage<String, String>.init(
    diskConfig: DiskConfig.init(name: "shared"),
    memoryConfig: MemoryConfig.init(),
    transformer: TransformerFactory.forCodable(ofType: String.self)
)

// MARK: - 存储协议
public protocol Storable: ModelType, Codable {

    static func objectKey(id: String?) -> String
    static func arrayKey(page: String?) -> String

    static func storeObject<Element: Codable>(_ object: Element.Type?, id: String?)
    static func storeArray<Element: Codable>(_ array: [Element.Type]?, page: String?)

    static func cachedObject<Element: Codable>(id: String?) -> Element?
    static func cachedArray<Element: Codable>(page: String?) -> [Element]?

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
    
    static func storeObject<Element: Codable>(_ object: Element.Type?, id: String?) {
        let key = self.objectKey(id: id)
        if let object = object {
            try? archiver.transformCodable(ofType: self).setObject(object as! Self, forKey: key)
        } else {
            try? archiver.removeObject(forKey: key)
        }
    }
    
    static func storeArray<Element: Codable>(_ array: [Element.Type]?, page: String?) {
        let key = self.arrayKey(page: page)
        if let array = array {
            try? archiver.transformCodable(ofType: [Self].self).setObject(array as! [Self], forKey: key)
        } else {
            try? archiver.removeObject(forKey: key)
        }
    }

    static func cachedObject<Element: Codable>(id: String?) -> Element? {
        let key = self.objectKey(id: id)
        if let object = try? archiver.transformCodable(ofType: self).object(forKey: key) {
            return object as? Element
        }
        if let path = Bundle.main.path(forResource: key, ofType: "json"),
            let json = try? String(contentsOfFile: path, encoding: .utf8) {
            return Self(JSONString: json) as? Element
        }
        return nil
    }

    static func cachedArray<Element: Codable>(page: String?) -> [Element]? {
        let key = self.arrayKey(page: page)
        if let array = try? archiver.transformCodable(ofType: [Self].self).object(forKey: key) {
            return array as? [Element]
        }
        if let path = Bundle.main.path(forResource: key, ofType: "json"),
            let json = try? String(contentsOfFile: path, encoding: .utf8) {
            return [Self](JSONString: json) as? [Element]
        }
        return nil
    }

    static func eraseObject(id: String? = nil) {
        let key = self.objectKey(id: id)
        try? archiver.removeObject(forKey: key)
    }

}

