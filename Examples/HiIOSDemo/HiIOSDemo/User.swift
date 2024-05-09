//
//  User.swift
//  HiIOSDemo
//
//  Created by 杨建祥 on 2024/5/9.
//

import Foundation
import RealmSwift
import HiIOS

//class User: BaseModel, UserType {
//    @Persisted(indexed: true) var userid: String?
//    @Persisted var username: String?
//    @Persisted var nickname: String?
//    @Persisted var avatar: String?
//    @Persisted var type: Int
//}


class MyUser: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var _id: ObjectId
    @Persisted(indexed: true) var userid: Int
    @Persisted var username: String?
    
    override class func propertiesMapping() -> [String : String] {
        [
            "username": "user_name"
        ]
    }
}
