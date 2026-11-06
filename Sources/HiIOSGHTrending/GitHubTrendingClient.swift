import Foundation
import HiIOSNetCore

/// 调用方注入传输；库不自动启动对 GitHub Trending HTML 的线上抓取。
public struct GitHubTrendingClient: Sendable {
    private let transport: any Transport
    private let parser: GitHubTrendingHTMLParser
    private let cache: GitHubTrendingPageCache
    private let cacheLifetime: TimeInterval
    private let now: @Sendable () -> Date

    public init(
        transport: any Transport,
        parser: GitHubTrendingHTMLParser = .init(),
        cacheLifetime: TimeInterval = 300,
        now: @escaping @Sendable () -> Date = { Date() }
    ) {
        self.transport = transport
        self.parser = parser
        self.cache = GitHubTrendingPageCache()
        self.cacheLifetime = cacheLifetime.isFinite ? max(0, cacheLifetime) : 0
        self.now = now
    }

    public func repositories(
        _ query: GitHubTrendingRepositoryQuery
    ) async throws(GitHubTrendingError) -> [GitHubTrendingRepository] {
        let url = try Self.requestURL(
            language: query.programmingLanguage,
            spokenLanguage: query.spokenLanguage,
            range: query.dateRange
        )
        let html = try await loadHTML(at: url)
        do {
            return try parser.repositories(from: html)
        } catch {
            await cache.remove(url)
            throw error
        }
    }

    public func developers(
        _ query: GitHubTrendingDeveloperQuery
    ) async throws(GitHubTrendingError) -> [GitHubTrendingDeveloper] {
        let url = try Self.requestURL(
            language: query.programmingLanguage,
            spokenLanguage: nil,
            range: query.dateRange,
            developers: true,
            sponsorableOnly: query.sponsorableOnly
        )
        let html = try await loadHTML(at: url)
        do {
            return try parser.developers(from: html)
        } catch {
            await cache.remove(url)
            throw error
        }
    }

    private func loadHTML(at url: URL) async throws(GitHubTrendingError) -> String {
        guard !Task.isCancelled else { throw .cancelled }
        let result = await cache.page(
            at: url,
            using: transport,
            lifetime: cacheLifetime,
            now: now
        )
        guard !Task.isCancelled else { throw .cancelled }
        return try result.get()
    }

    private static func requestURL(
        language: String?,
        spokenLanguage: String?,
        range: GitHubTrendingDateRange,
        developers: Bool = false,
        sponsorableOnly: Bool = false
    ) throws(GitHubTrendingError) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "github.com"
        components.percentEncodedPath = developers ? "/trending/developers" : "/trending"
        if let language, !language.isEmpty {
            guard validQueryValue(language, allowsSlash: false) else { throw .invalidQuery }
            var allowed = CharacterSet.urlPathAllowed
            allowed.remove(charactersIn: "/?#%+")
            guard let encoded = language.addingPercentEncoding(withAllowedCharacters: allowed) else {
                throw .invalidQuery
            }
            components.percentEncodedPath += "/\(encoded)"
        }
        var queryItems = [URLQueryItem(name: "since", value: range.rawValue)]
        if let spokenLanguage, !spokenLanguage.isEmpty {
            guard validQueryValue(spokenLanguage, allowsSlash: true) else { throw .invalidQuery }
            queryItems.append(URLQueryItem(name: "spoken_language_code", value: spokenLanguage))
        }
        if sponsorableOnly { queryItems.append(URLQueryItem(name: "sponsorable", value: "true")) }
        components.queryItems = queryItems
        guard let url = components.url else { throw .invalidQuery }
        return url
    }

    private static func validQueryValue(_ value: String, allowsSlash: Bool) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && value.count <= 64
            && (allowsSlash || !value.contains("/"))
            && !value.unicodeScalars.contains(where: CharacterSet.controlCharacters.contains)
    }
}

private struct TrendingPage: Sendable {
    let html: String
    let etag: String?
    let fetchedAt: Date
}

private actor GitHubTrendingPageCache {
    private var entries: [URL: TrendingPage] = [:]
    private var inFlight: [URL: Task<Result<TrendingPage, GitHubTrendingError>, Never>] = [:]
    private static let maximumHTMLBytes = 2_000_000

    func page(
        at url: URL,
        using transport: any Transport,
        lifetime: TimeInterval,
        now: @Sendable @escaping () -> Date
    ) async -> Result<String, GitHubTrendingError> {
        if let cached = entries[url],
           now().timeIntervalSince(cached.fetchedAt) >= 0,
           now().timeIntervalSince(cached.fetchedAt) < lifetime {
            return .success(cached.html)
        }
        if let current = inFlight[url] {
            return await current.value.map(\.html)
        }
        let cached = entries[url]
        let task = Task { await Self.load(url: url, transport: transport, cached: cached, now: now) }
        inFlight[url] = task
        let result = await task.value
        inFlight[url] = nil
        if case let .success(page) = result { entries[url] = page }
        return result.map(\.html)
    }

    func remove(_ url: URL) {
        entries[url] = nil
    }

    private static func load(
        url: URL,
        transport: any Transport,
        cached: TrendingPage?,
        now: @Sendable () -> Date
    ) async -> Result<TrendingPage, GitHubTrendingError> {
        var headers = ["Accept": "text/html"]
        if let etag = cached?.etag { headers["If-None-Match"] = etag }
        let response: HTTPResponse
        do {
            response = try await transport.send(HTTPRequest(url: url, headers: HTTPHeaders(headers)))
        } catch let error {
            return .failure(error == .cancelled ? .cancelled : .transport(error))
        }
        guard let finalURL = response.finalURL,
              finalURL.scheme?.lowercased() == "https",
              finalURL.host?.lowercased() == "github.com",
              finalURL.user == nil, finalURL.password == nil,
              finalURL.port == nil || finalURL.port == 443 else {
            return .failure(.invalidOrigin)
        }
        if response.statusCode == 304 {
            guard let cached else { return .failure(.httpStatus(304)) }
            return .success(TrendingPage(html: cached.html, etag: cached.etag, fetchedAt: now()))
        }
        if response.statusCode == 403 || response.statusCode == 429 {
            return .failure(.rateLimited(retryAfter: headerValue(response.headers["Retry-After"])))
        }
        guard response.isSuccessful else { return .failure(.httpStatus(response.statusCode)) }
        guard response.headers["Content-Type"]?.lowercased().hasPrefix("text/html") == true else {
            return .failure(.unsupportedContentType)
        }
        guard response.body.count <= maximumHTMLBytes else { return .failure(.responseTooLarge) }
        // 无效 UTF-8 必须报错，不能以替换字符继续解析 HTML。
        // swiftlint:disable:next non_optional_string_data_conversion
        guard let html = String(data: response.body, encoding: .utf8) else { return .failure(.schemaMismatch) }
        return .success(TrendingPage(
            html: html,
            etag: headerValue(response.headers["ETag"]),
            fetchedAt: now()
        ))
    }

    private static func headerValue(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty, raw.count <= 256,
              !raw.contains("\r"), !raw.contains("\n") else { return nil }
        return raw
    }
}
