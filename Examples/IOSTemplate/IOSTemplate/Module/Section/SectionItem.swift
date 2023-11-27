//
//  SectionItem.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2022/10/3.
//

import Foundation
import RxDataSources
import ReusableKit_Hi
import ObjectMapper_Hi
import HiIOS

enum SectionItem: IdentifiableType, Equatable {
    case label(LabelItem)
    
    var identity: String {
        var string = ""
        switch self {
        case let .label(item): string = item.description
        }
        return string
    }

    static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
        let result = (lhs.identity == rhs.identity)
        if result == false {
            switch lhs {
            case .label: log("item变化 -> label")
            }
        }
        return result
    }
    
}

