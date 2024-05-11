//
//  Realm+Frame.swift
//  HiIOS
//
//  Created by 杨建祥 on 2024/5/9.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import ObjectMapper

//open class BaseModel: Object, ModelType {
//    
//    @Persisted(primaryKey: true) public var _id: String
//    
//    public required override init() {
//        super.init()
//    }
//    
//    public required init?(map: ObjectMapper.Map) {
//    }
//    
//    public func mapping(map: ObjectMapper.Map) {
//    }
//    
//}

public extension Realm {
    
    static var `default`: Self { try! Self.init() }

}

// YJX_TODO 替换为RealmFetchable
public extension Object {
    
    static var current: Self? {
        let key = String(fullname: self)
        if let subject = subjects[key] as? BehaviorRelay<Self?> {
            return subject.value
        }
        if let object = Realm.default.objects(self).first {
            let subject = BehaviorRelay<Self?>(value: object)
            subjects[key] = subject
            return object
        }
        return nil
    }

//    static func storeObject(_ object: Self?, id: String? = nil) {
////        let key = self.objectKey(id: id)
////        if let object = object {
////            try? archiver.transformCodable(ofType: self).setObject(object, forKey: key)
////        } else {
////            try? archiver.removeObject(forKey: key)
////        }
//    }
    
//    static func eraseObject(id: String? = nil) {
//        let key = self.objectKey(id: id)
//        try? archiver.removeObject(forKey: key)
//        try! defaultRealm.write {
//            let objects = defaultRealm.objects(self)
//            defaultRealm.delete(objects)
//        }
//    }
    
}

//extension ModelType: ObjectKeyIdentifiable {
//    
//}

// ObjectKeyIdentifiable
//public extension Object: ModelType {
//    
//}

public extension RealmSwift.List {
    
    var array: [Element] { .init(self) }
    
}
