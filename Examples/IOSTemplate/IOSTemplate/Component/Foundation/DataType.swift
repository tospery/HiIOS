//
//  DataType.swift
//  IOSTemplate
//
//  Created by liaoya on 2022/7/21.
//

import Foundation
import HiIOS

enum TabBarKey {
    case dashboard
    case personal
}

enum Platform {
    case github
    case umeng
    case weixin
    
    var appId: String {
        switch self {
        case .github: return "826519ff4600bcfd06fe"
        case .umeng: return "6093ae3653b6726499ec3983"
        case .weixin: return UIApplication.shared.urlScheme(name: "weixin") ?? ""
        }
    }
    
    var appKey: String {
        switch self {
        case .github: return "c071b276632d4d2c219d3db8d3dee516e01b1c74"
        case .umeng: return "6093ae3653b6726499ec3983"
        case .weixin: return "f7f6a7c1cbe503c497151e076c0a4b4d"
        }
    }

//    var appSecret: String {
//        ""
//    }
    
    var appLink: String {
        switch self {
        case .weixin: return "https://tospery.com/swhub/"
        default: return ""
        }
    }

}

enum Page: String, Codable {
    case none
    // 趋势的
    case trendingRepos
    case trendingUsers
    
    static let trendingValues = [trendingRepos, trendingUsers]
    
    var title: String? {
        nil
    }
    
//    func apiPath(_ username: String, _ reponame: String) -> String {
//        switch self {
//        case .repositories:
//            return "/users/\(username)/repos"
//        case .stars:
//            return "/users/\(username)/starred"
//        case .followers:
//            return "/users/\(username)/followers"
//        case .following:
//            return "/users/\(username)/following"
//        case .watchs:
//            return "/users/\(username)/subscriptions"
//        case .forks:
//            return "/repos/\(username)/\(reponame)/forks"
//        case .watchers:
//            return "/repos/\(username)/\(reponame)/subscribers"
//        case .stargazers:
//            return "/repos/\(username)/\(reponame)/stargazers"
//        case .contributors:
//            return "/repos/\(username)/\(reponame)/contributors"
//        default:
//            break
//        }
//        return ""
//    }
    
}

enum ITAlertAction: AlertActionType, Equatable {
    case destructive
    case `default`
    case cancel
    case input
    case exit
    
    init?(string: String) {
        switch string {
        case ITAlertAction.cancel.title: self = ITAlertAction.cancel
        case ITAlertAction.exit.title: self = ITAlertAction.exit
        default: return nil
        }
    }

    var title: String? {
        switch self {
        case .destructive:  return R.string.localizable.sure(
            preferredLanguages: myLangs
        )
        case .default:  return R.string.localizable.oK(
            preferredLanguages: myLangs
        )
        case .cancel: return R.string.localizable.cancel(
            preferredLanguages: myLangs
        )
        case .exit: return R.string.localizable.exit(
            preferredLanguages: myLangs
        )
        default: return nil
        }
    }

    var style: UIAlertAction.Style {
        switch self {
        case .cancel:  return .cancel
        case .destructive, .exit:  return .destructive
        default: return .default
        }
    }

    static func == (lhs: ITAlertAction, rhs: ITAlertAction) -> Bool {
        switch (lhs, rhs) {
        case (.destructive, .destructive),
            (.default, .default),
            (.cancel, .cancel),
            (.input, .input),
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
        case .system: return R.string.localizable.followSystem(
            preferredLanguages: myLangs
        )
        case .chinese: return R.string.localizable.chinese(
            preferredLanguages: myLangs
        )
        case .english: return R.string.localizable.english(
            preferredLanguages: myLangs
        )
        }
    }
}
