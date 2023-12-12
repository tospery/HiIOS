//
//  Repo.swift
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
import ReusableKit
import ObjectMapper_Hi
import BonMot

struct Repo: Subjective, Eventable {
    
    enum Style: Int, Codable {
        case plain        = 0
        case basic
        case detail
    }
    
    enum Event {
    }

    // base
    var id = 0
    var url: String?
    var desc: String?
    // trending
    var currentPeriodStars: Int?
    var language: String?
    var languageColor: String?
    var builtBy: [BaseUser]?
    // other
    var `private` = false
    var nodeId: String?
    var archiveUrl: String?
    var archived = false
    var assigneesUrl: String?
    var blobsUrl: String?
    var branchesUrl: String?
    var cloneUrl: String?
    var collaboratorsUrl: String?
    var commentsUrl: String?
    var commitsUrl: String?
    var compareUrl: String?
    var contentsUrl: String?
    var contributorsUrl: String?
    var createdAt: String?
    var defaultBranch: String?
    var deploymentsUrl: String?
    var disabled = false
    var downloadsUrl: String?
    var eventsUrl: String?
    var fork = false
    var forksUrl: String?
    var gitCommitsUrl: String?
    var gitRefsUrl: String?
    var gitTagsUrl: String?
    var gitUrl: String?
    var hasDownloads = false
    var hasIssues = false
    var hasPages = false
    var hasProjects = false
    var hasWiki: Bool?
    var homepage: String?
    var hooksUrl: String?
    var htmlUrl: String?
    var issueCommentUrl: String?
    var issueEventsUrl: String?
    var issuesUrl: String?
    var keysUrl: String?
    var labelsUrl: String?
    var languagesUrl: String?
    var mergesUrl: String?
    var milestonesUrl: String?
    var mirrorUrl: String?
    var networkCount = 0
    var notificationsUrl: String?
    var openIssues = 0
    var openIssuesCount = 0
    var pullsUrl: String?
    var pushedAt: String?
    var releasesUrl: String?
    var size = 0
    var sshUrl: String?
    var stargazersUrl: String?
    var statusesUrl: String?
    var subscribersCount = 0
    var subscribersUrl: String?
    var subscriptionUrl: String?
    var svnUrl: String?
    var tagsUrl: String?
    var teamsUrl: String?
    var tempCloneToken: String?
    var treesUrl: String?
    var updatedAt: String?
    var watchers = 0
    var watchersCount = 0
    // 合并属性
    var ranking: Int?
    var forks = 0
    var stars = 0
    var owner = User.init()
    var name: String?
    var fullname: String?
    // 扩展属性
    // var branchs = [Branch].init()
    var style = Repo.Style.basic

    init() { }

    init?(map: Map) { }
        
    // swiftlint:disable function_body_length
    mutating func mapping(map: Map) {
        id                  <- map["id"]
        url                 <- map["url"]
        name                <- map["name"]
        ranking             <- map["ranking"]
        desc                <- map["description"]
        builtBy             <- map["builtBy"]
        currentPeriodStars  <- map["currentPeriodStars"]
        language            <- map["language"]
        languageColor       <- map["languageColor"]
        `private`           <- map["private"]
        nodeId              <- map["node_id"]
        archiveUrl          <- map["archive_url"]
        archived            <- map["archived"]
        assigneesUrl        <- map["assignees_url"]
        blobsUrl            <- map["blobs_url"]
        branchesUrl         <- map["branches_url"]
        cloneUrl            <- map["clone_url"]
        collaboratorsUrl    <- map["collaborators_url"]
        commentsUrl         <- map["comments_url"]
        commitsUrl          <- map["commits_url"]
        compareUrl          <- map["compare_url"]
        contentsUrl         <- map["contents_url"]
        contributorsUrl     <- map["contributors_url"]
        createdAt           <- map["created_at"]
        defaultBranch       <- map["default_branch"]
        deploymentsUrl      <- map["deployments_url"]
        disabled            <- map["disabled"]
        downloadsUrl        <- map["downloads_url"]
        eventsUrl           <- map["events_url"]
        fork                <- map["fork"]
        forksUrl            <- map["forks_url"]
        gitCommitsUrl       <- map["git_commits_url"]
        gitRefsUrl          <- map["git_refs_url"]
        gitTagsUrl          <- map["git_tags_url"]
        gitUrl              <- map["git_url"]
        hasDownloads        <- map["has_downloads"]
        hasIssues           <- map["has_issues"]
        hasPages            <- map["has_pages"]
        hasProjects         <- map["has_projects"]
        hasWiki             <- map["has_wiki"]
        homepage            <- map["homepage"]
        hooksUrl            <- map["hooks_url"]
        htmlUrl             <- map["html_url"]
        issueCommentUrl     <- map["issue_comment_url"]
        issueEventsUrl      <- map["issue_events_url"]
        issuesUrl           <- map["issues_url"]
        keysUrl             <- map["keys_url"]
        labelsUrl           <- map["labels_url"]
        language            <- map["language"]
        languagesUrl        <- map["languages_url"]
        mergesUrl           <- map["merges_url"]
        milestonesUrl       <- map["milestones_url"]
        mirrorUrl           <- map["mirror_url"]
        networkCount        <- map["network_count"]
        notificationsUrl    <- map["notifications_url"]
        openIssues          <- map["open_issues"]
        openIssuesCount     <- map["open_issues_count"]
        pullsUrl            <- map["pulls_url"]
        pushedAt            <- map["pushed_at"]
        releasesUrl         <- map["releases_url"]
        size                <- map["size"]
        sshUrl              <- map["ssh_url"]
        stargazersUrl       <- map["stargazers_url"]
        statusesUrl         <- map["statuses_url"]
        subscribersCount    <- map["subscribers_count"] // watchers
        subscribersUrl      <- map["subscribers_url"]
        subscriptionUrl     <- map["subscription_url"]
        svnUrl              <- map["svn_url"]
        tagsUrl             <- map["tags_url"]
        teamsUrl            <- map["teams_url"]
        tempCloneToken      <- map["temp_clone_token"]
        treesUrl            <- map["trees_url"]
        updatedAt           <- map["updated_at"]
        watchers            <- map["watchers"]
        watchersCount       <- map["watchers_count"]
        if htmlUrl?.isEmpty ?? true {
            htmlUrl         <- map["url"]
        }
//        // 扩展属性
        style               <- map["style"]
        // 合并属性
        owner               <- map["owner"]
        if !owner.isValid {
            owner.username  <- map["author"]
            owner.avatar    <- map["avatar"]
        }
        fullname            <- map["full_name"]
        if fullname?.isEmpty ?? true {
            fullname = "\(owner.username ?? "")/\(name ?? "")"
        }
        forks                <- map["forks|forks_count", nested: false, delimiter: "|"]
        stars                <- map["stars|stargazers_count", nested: false, delimiter: "|"]
    }
    // swiftlint:enable function_body_length
    
}
