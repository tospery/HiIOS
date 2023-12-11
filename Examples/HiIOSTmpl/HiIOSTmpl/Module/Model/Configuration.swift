//
//  Configuration.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/4.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import ReusableKit
import URLNavigator
import RswiftResources
import ObjectMapper_Hi
import HiIOS

struct Configuration: ModelType, Identifiable, Subjective, Eventable {
    
    enum Event {
    }
    
    var id = ""
    var theme = ColorTheme.indigo
    var localization = Localization.system
    
    init() {
    }

    init(id: String) {
        self.id = id
    }
    
    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        id                  <- map["id"]
        theme               <- map["theme"]
        localization        <- map["localization"]
    }
    
}
