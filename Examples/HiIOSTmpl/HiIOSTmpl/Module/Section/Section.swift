//
//  Section.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/10.
//

import Foundation
import RxDataSources
import ReusableKit
import ObjectMapper_Hi
import HiIOS

enum Section {
    case sectionItems(header: ModelType?, items: [SectionItem])
}

extension Section: AnimatableSectionModelType, Equatable {
    
    var identity: String {
        switch self {
        case let .sectionItems(header, _): return header?.description ?? ""
        }
    }

    var items: [SectionItem] {
        switch self {
        case let .sectionItems(_, items): return items
        }
    }

    init(original: Section, items: [SectionItem]) {
        switch original {
        case let .sectionItems(header, _):
            self = .sectionItems(header: header, items: items)
        }
    }
    
    static func == (lhs: Section, rhs: Section) -> Bool {
        return (lhs.identity == rhs.identity) && (lhs.items == rhs.items)
    }

}
