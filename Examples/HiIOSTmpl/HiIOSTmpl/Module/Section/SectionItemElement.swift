//
//  SectionItemElement.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/10.
//

import Foundation
import HiIOS

enum SectionItemElement {
    case appInfo
    case label(LabelInfo)
    case button(String?)
    case textField(String?)
    case textView(String?)
    case imageView(ImageSource?)
    
    func sectionItem(_ model: ModelType) -> SectionItem {
        switch self {
        case .appInfo: return .appInfo(.init(model))
        case .label: return .label(.init(model))
        case .button: return .button(.init(model))
        case .textField: return .textField(.init(model))
        case .textView: return .textView(.init(model))
        case .imageView: return .imageView(.init(model))
        }
    }
    
}

extension SectionItemElement: CustomStringConvertible {
    var description: String {
        switch self {
        case .appInfo: return "appInfo"
        case let .label(info): return "label-\(info.description)"
        case let .button(text): return "button-\(text ?? "")"
        case let .textField(text): return "textField-\(text ?? "")"
        case let .textView(text): return "textView-\(text ?? "")"
        case let .imageView(image): return "imageView-\(String(describing: image))"
        }
    }
}
