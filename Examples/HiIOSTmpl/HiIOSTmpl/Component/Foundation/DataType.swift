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

enum PagingElement: String, Codable {
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
    case settings       = 10, about, feedback
    case company        = 20, location, email, blog, nickname, bio
    case author         = 30, qqgroup, schemes, score, share
    case language       = 40, issues, pulls, branches, readme
    case theme          = 50, localization, cache
    
    // static let settingsValues = [theme, localization, cache]
    
    var title: String? {
//        switch self {
//        case .company: return R.string.localizable.company(
//            preferredLanguages: myLangs
//        )
//        case .location: return R.string.localizable.location(
//            preferredLanguages: myLangs
//        )
//        case .blog: return R.string.localizable.blog(
//            preferredLanguages: myLangs
//        )
//        case .nickname: return R.string.localizable.nickname(
//            preferredLanguages: myLangs
//        )
//        case .bio: return R.string.localizable.bio(
//            preferredLanguages: myLangs
//        )
//        case .issues: return R.string.localizable.issues(
//            preferredLanguages: myLangs
//        )
//        case .pulls: return R.string.localizable.pulls(
//            preferredLanguages: myLangs
//        )
//        case .branches: return R.string.localizable.branches(
//            preferredLanguages: myLangs
//        )
//        case .readme: return R.string.localizable.readme(
//            preferredLanguages: myLangs
//        ).uppercased()
//        case .settings: return R.string.localizable.settings(
//            preferredLanguages: myLangs
//        )
//        case .theme: return R.string.localizable.theme(
//            preferredLanguages: myLangs
//        )
//        case .localization: return R.string.localizable.language(
//            preferredLanguages: myLangs
//        )
//        case .cache: return R.string.localizable.clearCache(
//            preferredLanguages: myLangs
//        )
//        case .about: return R.string.localizable.about(
//            preferredLanguages: myLangs
//        )
//        case .feedback: return R.string.localizable.feedback(
//            preferredLanguages: myLangs
//        )
//            
//        case .author: return R.string.localizable.author(
//            preferredLanguages: myLangs
//        )
//        case .qqgroup: return R.string.localizable.qqGroup(
//            preferredLanguages: myLangs
//        )
//        case .schemes: return R.string.localizable.urlSchemes(
//            preferredLanguages: myLangs
//        )
//        case .score: return R.string.localizable.score(
//            preferredLanguages: myLangs
//        )
//        case .share: return R.string.localizable.share(
//            preferredLanguages: myLangs
//        )
//        default: return nil
//        }
        nil
    }
    
    var param: String? {
//        switch self {
//        case .company: return Parameter.company
//        case .location: return Parameter.location
//        case .blog: return Parameter.blog
//        case .nickname: return Parameter.name
//        case .bio: return Parameter.bio
//        default: return nil
//        }
        nil
    }
    
    var icon: String? {
//        switch self {
//        // user
//        case .company: return R.image.ic_company.name
//        case .location: return R.image.ic_location.name
//        case .email: return R.image.ic_email.name
//        case .blog: return R.image.ic_blog.name
//        // personal
//        case .settings: return R.image.ic_settings.name
//        case .about: return R.image.ic_about.name
//        case .feedback: return R.image.ic_feedback.name
//        // repo
//        case .language: return R.image.ic_language.name
//        case .issues: return R.image.ic_issues.name
//        case .pulls: return R.image.ic_pulls.name
//        case .branches: return R.image.ic_branches.name
//        case .readme: return R.image.ic_readme.name
//        default: return nil
//        }
        nil
    }
    
    var target: String? {
//        switch self {
//        case .nickname: return Router.shared.urlString(host: .modify, path: Parameter.nickname)
//        case .bio: return Router.shared.urlString(host: .modify, path: Parameter.bio)
//        case .company: return Router.shared.urlString(host: .modify, path: Parameter.company)
//        case .location: return Router.shared.urlString(host: .modify, path: Parameter.location)
//        case .blog: return Router.shared.urlString(host: .modify, path: Parameter.blog)
//        case .settings: return Router.shared.urlString(host: .settings)
//        case .about: return Router.shared.urlString(host: .about)
//        case .feedback: return Router.shared.urlString(host: .feedback)
//        case .schemes: return Router.shared.urlString(host: .urlscheme, path: .list)
//        default: return nil
//        }
        nil
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
