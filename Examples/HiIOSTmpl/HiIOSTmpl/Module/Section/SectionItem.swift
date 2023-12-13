//
//  SectionItem.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/10.
//

import Foundation
import RxDataSources
import ReusableKit
import ObjectMapper_Hi
import HiIOS

enum SectionItem: IdentifiableType, Equatable {
    case simple(SimpleItem)
    case appInfo(AppInfoItem)
    case event(EventItem)
    case repo(RepoItem)
    case user(UserItem)
    case label(LabelItem)
    case button(ButtonItem)
    case textField(TextFieldItem)
    case textView(TextViewItem)
    case imageView(ImageViewItem)
    
    var identity: String {
        var string = ""
        switch self {
        case let .simple(item): string = item.description
        case let .appInfo(item): string = item.description
        case let .event(item): string = item.description
        case let .repo(item): string = item.description
        case let .user(item): string = item.description
        case let .label(item): string = item.description
        case let .button(item): string = item.description
        case let .textField(item): string = item.description
        case let .textView(item): string = item.description
        case let .imageView(item): string = item.description
        }
        return string // String.init(string.sorted())
    }

    // swiftlint:disable cyclomatic_complexity
    static func == (lhs: SectionItem, rhs: SectionItem) -> Bool {
        let result = (lhs.identity == rhs.identity)
        if result == false {
            switch lhs {
            case .simple: log("item变化 -> simple")
            case .appInfo: log("item变化 -> appInfo")
            case .event: log("item变化 -> event")
            case .repo: log("item变化 -> repo")
            case .user: log("item变化 -> user")
            case .label: log("item变化 -> label")
            case .button: log("item变化 -> button")
            case .textField: log("item变化 -> textField")
            case .textView: log("item变化 -> textView")
            case .imageView: log("item变化 -> imageView")
            }
        }
        return result
    }
    // swiftlint:enable cyclomatic_complexity
    
}
