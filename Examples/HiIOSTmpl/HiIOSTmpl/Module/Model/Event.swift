//
//  Event.swift
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
import BonMot
import ReusableKit
import ObjectMapper_Hi

enum EventType: String, Codable {
    case unknown = ""
    case star = "WatchEvent"
    case fork = "ForkEvent"
    case create = "CreateEvent"
    case delete = "DeleteEvent"
    case member = "MemberEvent"
    case push = "PushEvent"
    case release = "ReleaseEvent"
    case issueHandle = "IssuesEvent"
    case issueComment = "IssueCommentEvent"
    case commitComment = "CommitCommentEvent"
    case organizationBlock = "OrgBlockEvent"
    case `public` = "PublicEvent"
    case pull = "PullRequestEvent"
    case pullReviewComment = "PullRequestReviewCommentEvent"
    
    var title: String? {
//        switch self {
//        case .star: return R.string.localizable.eventStar(
//            preferredLanguages: myLangs
//        )
//        case .fork: return R.string.localizable.eventFork(
//            preferredLanguages: myLangs
//        )
//        case .issueHandle: return R.string.localizable.eventIssueHandle(
//            preferredLanguages: myLangs
//        )
//        case .issueComment: return R.string.localizable.eventIssueComment(
//            preferredLanguages: myLangs
//        )
//        case .create: return R.string.localizable.eventCreate(
//            preferredLanguages: myLangs
//        )
//        case .delete: return R.string.localizable.eventDelete(
//            preferredLanguages: myLangs
//        )
//        case .pull: return R.string.localizable.eventPull(
//            preferredLanguages: myLangs
//        )
//        case .push: return R.string.localizable.eventPush(
//            preferredLanguages: myLangs
//        )
//        default: return nil
//        }
        nil
    }
    
    var action: String? {
        switch self {
        case .create: return "created"
        case .delete: return "deleted"
        case .fork: return "forked"
        case .star: return "starred"
        case .push: return "pushed"
        default: return nil
        }
    }
    
    var icon: UIImage? {
//        switch self {
//        case .star: return R.image.ic_event_star()
//        case .fork: return R.image.ic_event_fork()
//        case .issueHandle: return R.image.ic_event_issue_handle()
//        case .issueComment: return R.image.ic_event_issue_comment()
//        case .create: return R.image.ic_event_create()
//        case .delete: return R.image.ic_event_delete()
//        case .pull: return R.image.ic_event_pull()
//        case .push: return R.image.ic_event_push()
//        default:
//            analytics.log(.eventParseFail(name: self.rawValue))
//            return nil
//        }
        nil
    }
    
}

struct Event: Subjective, Eventable {
    
    enum Event {
    }
    
    var id = ""
    var type = EventType.unknown
//    var actor: BaseUser?
//    var repo: BaseRepo?
//    var payload: Payload?
    var `public`: Bool?
    var createdAt: String?
    
//    var time: String? {
//        guard let string = self.createdAt else { return nil }
//        guard let date = Date.init(iso8601: string) else { return nil }
//        return date.string(withFormat: "yyyy-MM-dd HH:mm")
//    }
//    
//    var content: [NSAttributedString]? {
//        let user = (self.actor?.username ?? R.string.localizable.unknown(
//            preferredLanguages: myLangs
//        ))
//            .styled(with: .font(.bold(16)), .color(.primary))
//        var repo = (self.repo?.name ?? R.string.localizable.unknown(
//            preferredLanguages: myLangs
//        ))
//            .styled(with: .font(.bold(16)), .color(.primary))
//        let action = self.payload?.action ?? self.type.action ?? ""
//        switch self.type {
//        case .create, .delete:
//            return [
//                .composed(of: [
//                    user,
//                    " \(action) branch \(self.payload?.ref ?? "") at "
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    repo
//                ]),
//                user,
//                repo
//            ]
//        case .pull:
//            return [
//                .composed(of: [
//                    user,
//                    " \(action) pull request \(self.payload?.ref ?? "") in "
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    repo
//                ]),
//                user,
//                repo
//            ]
//        case .push:
//            return [
//                .composed(of: [
//                    user,
//                    " \(action) to \(self.payload?.ref?.components(separatedBy: "/").last ?? "") in "
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    repo
//                ]),
//                user,
//                repo
//            ]
//        case .star:
//            return [
//                .composed(of: [
//                    user,
//                    " \(action) "
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    (self.repo?.name ?? R.string.localizable.unknown(
//                        preferredLanguages: myLangs
//                    ))
//                        .styled(with: .font(.normal(16)), .color(.title))
//                ]),
//                user
//            ]
//        case .fork:
//            repo = (self.payload?.forkee?.fullname ?? "")
//                .styled(with: .font(.bold(16)), .color(.primary))
//            return [
//                .composed(of: [
//                    user,
//                    " \(action) "
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    (self.repo?.name ?? R.string.localizable.unknown(
//                        preferredLanguages: myLangs
//                    ))
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    " \(R.string.localizable.to(preferredLanguages: myLangs).lowercased()) "
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    repo
//                ]),
//                user,
//                repo
//            ]
//        case .issueHandle, .issueComment:
//            return [
//                .composed(of: [
//                    user,
//                    (" \(action) issue ")
//                        .styled(with: .font(.normal(16)), .color(.title)),
//                    repo,
//                    Special.nextLine,
//                    (self.payload?.issue?.title ?? "")
//                        .styled(with: .font(.normal(13)), .color(.foreground))
//                ]),
//                user,
//                repo
//            ]
//        default:
//            return nil
//        }
//    }
    
    init() { }

    init?(map: Map) { }

    mutating func mapping(map: Map) {
        id              <- map["id"]
        type            <- map["type"]
//        actor           <- map["actor"]
//        repo            <- map["repo"]
//        payload         <- map["payload"]
        `public`        <- map["public"]
        createdAt       <- map["created_at"]
    }
    
}
