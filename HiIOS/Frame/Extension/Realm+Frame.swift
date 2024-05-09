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

// YJX_TODO 替换为RealmFetchable
public extension Object {
    
    static var current: Self? {
//        // EmbeddedObject Projection AsymmetricObject RealmFetchable
//        // let aa = defaultRealm.add(T##object: Object##Object)
//        let aaa = defaultRealm.delete(<#T##object: ObjectBase##ObjectBase#>)
        let key = String(fullname: self)
        if let subject = subjects[key] as? BehaviorRelay<Self?> {
            return subject.value
        }
        if let object = defaultRealm.objects(self).first {
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
    
    static func eraseObject(id: String? = nil) {
//        let key = self.objectKey(id: id)
//        try? archiver.removeObject(forKey: key)
        try! defaultRealm.write {
            let objects = defaultRealm.objects(self)
            defaultRealm.delete(objects)
        }
    }
    
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
