import Foundation
import HiIOSNetCore

/// GitHub 未版本化 Trending HTML 的查询时间范围。
public enum GitHubTrendingDateRange: String, CaseIterable, Codable, Sendable {
    case daily
    case weekly
    case monthly
}

public struct GitHubTrendingRepository: Equatable, Hashable, Identifiable, Sendable {
    public let rank: Int
    public let owner: String
    public let name: String
    public let summary: String?
    public let programmingLanguage: String?
    public let stars: String?
    public let forks: String?
    public let starsInPeriod: String?

    public var id: String { "\(owner)/\(name)" }

    public init(
        rank: Int,
        owner: String,
        name: String,
        summary: String? = nil,
        programmingLanguage: String? = nil,
        stars: String? = nil,
        forks: String? = nil,
        starsInPeriod: String? = nil
    ) {
        self.rank = rank
        self.owner = owner
        self.name = name
        self.summary = summary
        self.programmingLanguage = programmingLanguage
        self.stars = stars
        self.forks = forks
        self.starsInPeriod = starsInPeriod
    }
}

public struct GitHubTrendingDeveloper: Equatable, Hashable, Identifiable, Sendable {
    public let rank: Int
    public let login: String
    public let displayName: String?
    public let popularRepository: String?
    public let summary: String?

    public var id: String { login }

    public init(
        rank: Int,
        login: String,
        displayName: String? = nil,
        popularRepository: String? = nil,
        summary: String? = nil
    ) {
        self.rank = rank
        self.login = login
        self.displayName = displayName
        self.popularRepository = popularRepository
        self.summary = summary
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
