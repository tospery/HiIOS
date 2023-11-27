//
//  SectionItemValue.swift
//  IOSTemplate
//
//  Created by 杨建祥 on 2022/10/3.
//

import Foundation
import HiIOS

enum SectionItemElement {
    case label(LabelInfo)
    
    func sectionItem(_ model: ModelType) -> SectionItem {
        switch self {
        case .label: return .label(.init(model))
        }
    }
    
}

extension SectionItemElement: CustomStringConvertible {
    var description: String {
        switch self {
        case let .label(info): return "label-\(info.description)"
        }
    }
}
