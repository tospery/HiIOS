//
//  Storable+Ex.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import Foundation
import Cache
import HiIOS

// swiftlint:disable force_try
let archiver = try! Storage<String, String>.init(
    diskConfig: DiskConfig.init(name: "shared"),
    memoryConfig: MemoryConfig.init(),
    transformer: TransformerFactory.forCodable(ofType: String.self)
)
// swiftlint:enable force_try

extension Storable {

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
    
}
