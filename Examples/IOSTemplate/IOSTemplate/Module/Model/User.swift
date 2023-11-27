//
//  User.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2020/11/28.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import Rswift
import HiIOS
import ReusableKit_Hi
import ObjectMapper_Hi

struct User: ModelType, Identifiable, Subjective, Eventable {
    
    enum Event {
    }
    
    var id = ""
    var token: String?
    var username: String?
    
    var isLogined: Bool {
        if self.id.isEmpty ||
            self.token?.isEmpty ?? true ||
            self.username?.isEmpty ?? true {
            return false
        }
        return true
    }
    
    init() {
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id                  <- map["id"]
        token               <- map["token"]
        username            <- map["username"]
    }
    
    static func update(_ user: User?, reactive: Bool) {
        let old = Self.current
        let new = user
        if old == new {
            log("相同用户，不需要处理！！！")
            return
        }
        let oldLogined = old?.isValid ?? false
        let newLogined = new?.isValid ?? false
        if !oldLogined && newLogined {
            log("用户登录: \(String(describing: new))")
        } else if oldLogined && !newLogined {
            log("用户退出")
        } else {
            log("用户更新: \(String(describing: new))")
        }
        Subjection.update(self, new, reactive)
//        let userid = new?.id.string
//        if userid != Preference.current?.id {
//            Subjection.update(
//                Preference.self,
//                Preference.cachedObject(id: userid) ?? .init(id: userid ?? ""),
//                true
//            )
//        }
    }
    
}
