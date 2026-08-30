import Foundation
import HiIOSNetwork

/// GitHub 未版本化 Trending HTML 的查询时间范围。
public enum GitHubTrendingDateRange: String, CaseIterable, Codable, Sendable {
    case daily, weekly, monthly
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

    public init(rank: Int, owner: String, name: String, summary: String? = nil, programmingLanguage: String? = nil, stars: String? = nil, forks: String? = nil, starsInPeriod: String? = nil) {
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

    public init(rank: Int, login: String, displayName: String? = nil, popularRepository: String? = nil, summary: String? = nil) {
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

    public init(programmingLanguage: String? = nil, spokenLanguage: String? = nil, dateRange: GitHubTrendingDateRange = .daily) {
        self.programmingLanguage = programmingLanguage
        self.spokenLanguage = spokenLanguage
        self.dateRange = dateRange
    }
}

public struct GitHubTrendingDeveloperQuery: Equatable, Sendable {
    public var programmingLanguage: String?
    public var dateRange: GitHubTrendingDateRange
    public var sponsorableOnly: Bool

    public init(programmingLanguage: String? = nil, dateRange: GitHubTrendingDateRange = .daily, sponsorableOnly: Bool = false) {
        self.programmingLanguage = programmingLanguage
        self.dateRange = dateRange
        self.sponsorableOnly = sponsorableOnly
    }
}

public enum GitHubTrendingError: Error, Equatable, Sendable {
    case invalidOrigin
    case httpStatus(Int)
    case unsupportedContentType
    case schemaMismatch
    case rateLimited(retryAfter: String?)
    case cancelled
    case transport(NetworkError)
}

/// 传输可由调用方注入；AtlasHub 不在 Production 装配该 client，避免未经确认的默认线上抓取。
public struct GitHubTrendingClient: Sendable {
    private let transport: any Transport
    private let parser: GitHubTrendingHTMLParser

    public init(transport: any Transport, parser: GitHubTrendingHTMLParser = .init()) {
        self.transport = transport
        self.parser = parser
    }

    public func repositories(_ query: GitHubTrendingRepositoryQuery) async throws(GitHubTrendingError) -> [GitHubTrendingRepository] {
        let html = try await loadHTML(path: requestPath(language: query.programmingLanguage, spokenLanguage: query.spokenLanguage, range: query.dateRange))
        return try parser.repositories(from: html)
    }

    public func developers(_ query: GitHubTrendingDeveloperQuery) async throws(GitHubTrendingError) -> [GitHubTrendingDeveloper] {
        let html = try await loadHTML(path: requestPath(language: query.programmingLanguage, spokenLanguage: nil, range: query.dateRange, developers: true, sponsorableOnly: query.sponsorableOnly))
        return try parser.developers(from: html)
    }

    private func loadHTML(path: String) async throws(GitHubTrendingError) -> String {
        guard let url = URL(string: "https://github.com\(path)") else { throw .invalidOrigin }
        let response: HTTPResponse
        do { response = try await transport.send(HTTPRequest(url: url, headers: HTTPHeaders(["Accept": "text/html"]))) }
        catch let error { throw error == .cancelled ? .cancelled : .transport(error) }
        if response.statusCode == 429 || response.statusCode == 403 { throw .rateLimited(retryAfter: response.headers["Retry-After"]) }
        guard response.isSuccessful else { throw .httpStatus(response.statusCode) }
        guard response.headers["Content-Type"]?.lowercased().contains("text/html") != false else { throw .unsupportedContentType }
        guard let html = String(data: response.body, encoding: .utf8) else { throw .schemaMismatch }
        return html
    }

    private func requestPath(language: String?, spokenLanguage: String?, range: GitHubTrendingDateRange, developers: Bool = false, sponsorableOnly: Bool = false) -> String {
        let languagePath = language?.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed).map { "/\($0)" } ?? ""
        var items = [URLQueryItem(name: "since", value: range.rawValue)]
        if let spokenLanguage, !spokenLanguage.isEmpty { items.append(URLQueryItem(name: "spoken_language_code", value: spokenLanguage)) }
        if developers { items.append(URLQueryItem(name: "developers", value: "true")) }
        if sponsorableOnly { items.append(URLQueryItem(name: "sponsorable", value: "true")) }
        var components = URLComponents()
        components.queryItems = items
        return "/trending\(languagePath)\(components.percentEncodedQuery.map { "?\($0)" } ?? "")"
    }
}

/// 仅处理最小、稳定的 HTML 结构；结构不匹配会显式失败，绝不伪装成空榜单。
public struct GitHubTrendingHTMLParser: Sendable {
    public init() {}

    public func repositories(from html: String) throws(GitHubTrendingError) -> [GitHubTrendingRepository] {
        let articles = html.matches("(?is)<article[^>]*>(.*?)</article>")
        let result = articles.enumerated().compactMap { index, article -> GitHubTrendingRepository? in
            guard let reference = article.firstMatch("href=[\\\"']/(?!topics/)([^/\\\"'#?\\s]+)/([^/\\\"'#?\\s]+)[\\\"']") else { return nil }
            return GitHubTrendingRepository(rank: index + 1, owner: reference[0], name: reference[1], summary: article.text(after: "<p", until: "</p>"), programmingLanguage: article.text(after: "itemprop=[\\\"']programmingLanguage[\\\"'][^>]*>", until: "<"), stars: article.text(after: "/stargazers[\\\"'][^>]*>", until: "<"), forks: article.text(after: "/forks[\\\"'][^>]*>", until: "<"), starsInPeriod: article.text(after: "stars today", until: "<"))
        }
        guard !result.isEmpty else { throw .schemaMismatch }
        return result
    }

    public func developers(from html: String) throws(GitHubTrendingError) -> [GitHubTrendingDeveloper] {
        let articles = html.matches("(?is)<article[^>]*>(.*?)</article>")
        let result = articles.enumerated().compactMap { index, article -> GitHubTrendingDeveloper? in
            guard let login = article.firstMatch("href=[\\\"']/([^/\\\"'#?\\s]+)[\\\"']")?.first else { return nil }
            return GitHubTrendingDeveloper(rank: index + 1, login: login, displayName: article.text(after: "<h1[^>]*>", until: "</h1>"), popularRepository: article.firstMatch("href=[\\\"']/([^\\\"'#?\\s]+/[^\\\"'#?\\s]+)[\\\"']")?.first, summary: article.text(after: "<p", until: "</p>"))
        }
        guard !result.isEmpty else { throw .schemaMismatch }
        return result
    }
}

private extension String {
    func matches(_ pattern: String) -> [String] {
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return [] }
        return expression.matches(in: self, range: NSRange(startIndex..., in: self)).compactMap { Range($0.range(at: 1), in: self).map { String(self[$0]) } }
    }

    func firstMatch(_ pattern: String) -> [String]? {
        guard let expression = try? NSRegularExpression(pattern: pattern), let match = expression.firstMatch(in: self, range: NSRange(startIndex..., in: self)) else { return nil }
        return (1..<match.numberOfRanges).compactMap { Range(match.range(at: $0), in: self).map { String(self[$0]) } }
    }

    func text(after pattern: String, until terminator: String) -> String? {
        guard let value = firstMatch("(?is)\(pattern)(.*?)\(terminator)")?.first else { return nil }
        let plain = value.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression).replacingOccurrences(of: "&amp;", with: "&").trimmingCharacters(in: .whitespacesAndNewlines)
        return plain.isEmpty ? nil : plain
    }
}
