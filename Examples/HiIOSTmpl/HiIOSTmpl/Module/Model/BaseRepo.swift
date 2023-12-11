//
//  BaseRepo.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/12.
//

import Foundation
import RxSwift
import RxCocoa
import ReactorKit
import URLNavigator
import RswiftResources
import HiIOS
import ReusableKit
import ObjectMapper_Hi

struct BaseRepo: Subjective, Eventable {
    
    enum Event {
    }

    var id = 0
    var url: String?
    var name: String?
    var desc: String?

    init() { }

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        id          <- map["id"]
        url         <- map["url"]
        name        <- map["name"]
        desc        <- map["description"]
    }

}
