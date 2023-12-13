//
//  DataType.swift
//  HiIOSTmpl
//
//  Created by 杨建祥 on 2023/12/4.
//

import Foundation
import HiIOS

enum TabBarKey {
    case trending
    case favorite
    case personal
}

enum Page: String, Codable {
    case none
    case trendingRepos
    case trendingUsers
    
    static let trendingValues = [trendingRepos, trendingUsers]
    
    var title: String? {
        switch self {
        case .trendingRepos: return R.string(preferredLanguages: myLangs).localizable.repositories()
        case .trendingUsers: return R.string(preferredLanguages: myLangs).localizable.developers()
        default: return nil
        }
    }
    
}

struct Metric {
    
    static let menuHeight   = 44.f
    
    struct Personal {
        static let parallaxTopHeight    = 244.0
        static let parallaxAllHeight    = 290.0
    }
    
    struct BasicCell {
        static let height = 114.f
        static let forksWidth = 55.f
        static let avatarSize = CGSize.init(44.f)
        static let margin = UIEdgeInsets.init(top: 10, left: 10, bottom: 5, right: 5)
        static let padding = UIOffset.init(horizontal: 10, vertical: 8)
    }
    
    struct DetailCell {
        static let maxLines = 5
        static let avatarSize = CGSize.init(60.f)
        static let margin = UIEdgeInsets.init(top: 10, left: 15, bottom: 5, right: 5)
        static let padding = UIOffset.init(horizontal: 10, vertical: 8)
    }
    
}

enum CellId: Int {
    case space          = 0, button
    case settings       = 10, about
    
    static let personalValues = [settings, about]
    
    var title: String? {
        switch self {
        case .settings: return R.string(preferredLanguages: myLangs).localizable.settings()
        case .about: return R.string(preferredLanguages: myLangs).localizable.about()
        default: return nil
        }
    }
    
    var icon: String? {
        switch self {
        case .settings: return R.image.ic_settings.name
        case .about: return R.image.ic_about.name
        default: return nil
        }
    }
    
    var target: String? {
        switch self {
        case .settings: return Router.shared.urlString(host: .settings)
        case .about: return Router.shared.urlString(host: .about)
        default: return nil
        }
    }
    
}

enum HTAlertAction: AlertActionType, Equatable {
    case destructive
    case `default`
    case cancel
    case exit
    
    init?(string: String) {
        switch string {
        case HTAlertAction.cancel.title: self = HTAlertAction.cancel
        case HTAlertAction.exit.title: self = HTAlertAction.exit
        default: return nil
        }
    }

    var title: String? {
        switch self {
        case .destructive:  return R.string(preferredLanguages: myLangs).localizable.sure()
        case .default:  return R.string(preferredLanguages: myLangs).localizable.oK()
        case .cancel: return R.string(preferredLanguages: myLangs).localizable.cancel()
        case .exit: return R.string(preferredLanguages: myLangs).localizable.exit()
        }
    }

    var style: UIAlertAction.Style {
        switch self {
        case .cancel:  return .cancel
        case .destructive, .exit:  return .destructive
        default: return .default
        }
    }

    static func == (lhs: HTAlertAction, rhs: HTAlertAction) -> Bool {
        switch (lhs, rhs) {
        case (.destructive, .destructive),
            (.default, .default),
            (.cancel, .cancel),
            (.exit, .exit):
            return true
        default:
            return false
        }
    }
}

enum Localization: String, CustomStringConvertible, Codable {
    case system     = "system"
    case chinese    = "zh-Hans"
    case english    = "en"
    
    static let allValues = [system, chinese, english]
    
    static var preferredLanguages: [String]? {
        Configuration.current?.localization.preferredLanguages
    }
    
    var preferredLanguages: [String]? {
        switch self {
        case .system: return nil
        default: return [self.rawValue]
        }
    }
    
    var description: String {
        switch self {
        case .system: return R.string(preferredLanguages: myLangs).localizable.followSystem()
        case .chinese: return R.string(preferredLanguages: myLangs).localizable.chinese()
        case .english: return R.string(preferredLanguages: myLangs).localizable.english()
        }
    }
}
