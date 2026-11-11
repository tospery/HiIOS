import Foundation
import HiIOSNetCore

/// GitHub 未版本化 Trending HTML 的查询时间范围。
public enum GitHubTrendingDateRange: String, CaseIterable, Codable, Sendable {
    case daily
    case weekly
    case monthly
}

/// 榜单条目中出现的 GitHub 账号摘要；头像只接受 GitHub 自有的 HTTPS 图片地址。
public struct GitHubTrendingContributor: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let login: String
    public let avatarURL: URL?

    public var id: String { login }

    public init(login: String, avatarURL: URL? = nil) {
        self.login = login
        self.avatarURL = avatarURL
    }
}

public struct GitHubTrendingRepository: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let rank: Int
    public let owner: String
    public let name: String
    public let summary: String?
    public let programmingLanguage: String?
    /// 页面给出的语言色，形如 `#3572A5`；缺失或格式异常时为 nil。
    public let programmingLanguageColor: String?
    public let stars: Int?
    public let forks: Int?
    /// 查询时间范围内新增的星标数；统计周期由发起查询的 `dateRange` 决定。
    public let starsInPeriod: Int?
    public let builtBy: [GitHubTrendingContributor]

    public var id: String { "\(owner)/\(name)" }

    public init(
        rank: Int,
        owner: String,
        name: String,
        summary: String? = nil,
        programmingLanguage: String? = nil,
        programmingLanguageColor: String? = nil,
        stars: Int? = nil,
        forks: Int? = nil,
        starsInPeriod: Int? = nil,
        builtBy: [GitHubTrendingContributor] = []
    ) {
        self.rank = rank
        self.owner = owner
        self.name = name
        self.summary = summary
        self.programmingLanguage = programmingLanguage
        self.programmingLanguageColor = programmingLanguageColor
        self.stars = stars
        self.forks = forks
        self.starsInPeriod = starsInPeriod
        self.builtBy = builtBy
    }
}

public struct GitHubTrendingDeveloper: Codable, Equatable, Hashable, Identifiable, Sendable {
    public let rank: Int
    public let login: String
    public let displayName: String?
    public let avatarURL: URL?
    /// 没有热门仓库的条目（多为组织成员）页面改为展示所属组织。
    public let company: String?
    /// 热门仓库的 `owner/name`。
    public let popularRepository: String?
    public let popularRepositorySummary: String?

    public var id: String { login }

    public init(
        rank: Int,
        login: String,
        displayName: String? = nil,
        avatarURL: URL? = nil,
        company: String? = nil,
        popularRepository: String? = nil,
        popularRepositorySummary: String? = nil
    ) {
        self.rank = rank
        self.login = login
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.company = company
        self.popularRepository = popularRepository
        self.popularRepositorySummary = popularRepositorySummary
    }
}

public struct GitHubTrendingRepositoryQuery: Equatable, Sendable {
    public var programmingLanguage: String?
    public var spokenLanguage: String?
    public var dateRange: GitHubTrendingDateRange

    public init(
        programmingLanguage: String? = nil,
        spokenLanguage: String? = nil,
        dateRange: GitHubTrendingDateRange = .daily
    ) {
        self.programmingLanguage = programmingLanguage
        self.spokenLanguage = spokenLanguage
        self.dateRange = dateRange
    }
}

public struct GitHubTrendingDeveloperQuery: Equatable, Sendable {
    public var programmingLanguage: String?
    public var dateRange: GitHubTrendingDateRange
    public var sponsorableOnly: Bool

    public init(
        programmingLanguage: String? = nil,
        dateRange: GitHubTrendingDateRange = .daily,
        sponsorableOnly: Bool = false
    ) {
        self.programmingLanguage = programmingLanguage
        self.dateRange = dateRange
        self.sponsorableOnly = sponsorableOnly
    }
}

public enum GitHubTrendingError: Error, Equatable, Sendable {
    case invalidQuery
    case invalidOrigin
    case httpStatus(Int)
    case unsupportedContentType
    case responseTooLarge
    case schemaMismatch
    case rateLimited(retryAfter: String?)
    case cancelled
    case transport(NetworkError)
}
