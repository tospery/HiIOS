//
//  Subjection.swift
//  HiIOS
//
//  Created by liaoya on 2022/7/19.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import ObjectMapper

public var subjects: [String: Any] = [:]

//final public class Subjection {
//    
//    public class func `for`<T: Subjective>(_ type: T.Type) -> BehaviorRelay<T?> {
//        let key = String(fullname: type)
//        if let subject = subjects[key] as? BehaviorRelay<T?> {
//            return subject
//        }
//        let subject = BehaviorRelay<T?>(value: type.current)
//        subjects[key] = subject
//        return subject
//    }
//    
//    public class func update<T: Subjective>(_ type: T.Type, _ value: T?, _ reactive: Bool = true) {
//        var key: String?
//        if let id = value?.id as? String, !id.isEmpty {
//            key = id
//        }
//        if let value = value {
//            T.storeObject(value, id: key)
//        } else {
//            T.eraseObject(id: key)
//        }
//        if reactive {
//            self.for(type).accept(value)
//        } else {
//            let key = String(fullname: type)
//            subjects[key] = value
//        }
//    }
//
//}

final public class Subjection {
    
    public class func `for`<T: Object>(_ type: T.Type) -> BehaviorRelay<T?> {
        let key = String(fullname: type)
        if let subject = subjects[key] as? BehaviorRelay<T?> {
            return subject
        }
        let subject = BehaviorRelay<T?>(value: type.current)
        subjects[key] = subject
        return subject
    }
    
    public class func update<T: Object>(_ type: T.Type, _ value: T?, _ reactive: Bool = true) {
//        if let value = value {
//            try! defaultRealm.write {
//                defaultRealm.delete(value)
//                defaultRealm.add(value)
//            }
//        } else {
//            let objects = defaultRealm.objects(type)
//            try! defaultRealm.write {
//                defaultRealm.delete(objects)
//            }
//        }
//        if reactive {
//            self.for(type).accept(value)
//        } else {
//            let key = String(fullname: type)
//            subjects[key] = value
//        }
    }

}

public protocol Subjective: Storable {
    static var current: Self? { get }
}

public extension Subjective {
    
    static var current: Self? {
        // YJX_TODO
//        let key = String(fullname: self)
//        if let subject = subjects[key] as? BehaviorRelay<Self?> {
//            return subject.value
//        }
//        if let object = Self.cachedObject(id: nil) {
//            let subject = BehaviorRelay<Self?>(value: object)
//            subjects[key] = subject
//            return object
//        }
        return nil
    }
    
}
