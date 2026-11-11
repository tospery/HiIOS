import Foundation
import SwiftSoup

/// 只接受明确的榜单容器；结构变化或部分损坏时显式失败。
public struct GitHubTrendingHTMLParser: Sendable {
    public init() {}

    public func repositories(from html: String) throws(GitHubTrendingError) -> [GitHubTrendingRepository] {
        do {
            let document = try SwiftSoup.parse(html)
            guard try document.select("main").first() != nil else { throw GitHubTrendingError.schemaMismatch }
            var result: [GitHubTrendingRepository] = []
            for article in try document.select("main article.Box-row") {
                guard let link = try article.select("h2 a[href]").first(),
                      let reference = Self.pathComponents(try link.attr("href"), count: 2) else {
                    throw GitHubTrendingError.schemaMismatch
                }
                result.append(GitHubTrendingRepository(
                    rank: result.count + 1,
                    owner: reference[0],
                    name: reference[1],
                    summary: try Self.text(in: article, selector: "p"),
                    programmingLanguage: try Self.text(in: article, selector: "[itemprop=programmingLanguage]"),
                    programmingLanguageColor: try Self.languageColor(in: article),
                    stars: Self.count(try Self.text(in: article, selector: "a[href$=\"/stargazers\"]")),
                    forks: Self.count(try Self.text(in: article, selector: "a[href$=\"/forks\"]")),
                    starsInPeriod: try Self.starsInPeriod(in: article),
                    builtBy: try Self.builtBy(in: article)
                ))
            }
            if result.isEmpty {
                guard try document.select("main .blankslate").first() != nil else {
                    throw GitHubTrendingError.schemaMismatch
                }
            }
            return result
        } catch {
            throw .schemaMismatch
        }
    }

    public func developers(from html: String) throws(GitHubTrendingError) -> [GitHubTrendingDeveloper] {
        do {
            let document = try SwiftSoup.parse(html)
            guard try document.select("main").first() != nil else { throw GitHubTrendingError.schemaMismatch }
            var result: [GitHubTrendingDeveloper] = []
            for article in try document.select("main article.Box-row") {
                // 条目标题是开发者；嵌套 article 的标题是其热门仓库，两者都可能用 h1 或 h2。
                let headings = try article.select("h1 a[href], h2 a[href]").array()
                guard let first = headings.first,
                      let identity = Self.pathComponents(try first.attr("href"), count: 1) else {
                    throw GitHubTrendingError.schemaMismatch
                }
                var popularRepository: String?
                var popularSummary: String?
                for link in headings.dropFirst() {
                    guard let reference = Self.pathComponents(try link.attr("href"), count: 2) else { continue }
                    popularRepository = reference.joined(separator: "/")
                    let container = link.parents().array().first { $0.tagName() == "article" && $0 !== article }
                    if let container {
                        popularSummary = try Self.text(in: container, selector: "div.f6.color-fg-muted.mt-1, p")
                    }
                    break
                }
                if popularRepository == nil { popularSummary = nil }
                result.append(GitHubTrendingDeveloper(
                    rank: result.count + 1,
                    login: identity[0],
                    displayName: Self.trimmed(try first.text()),
                    avatarURL: Self.avatarURL(try article.select("img[src]").first()?.attr("src")),
                    company: try Self.metadata(in: article, icon: "octicon-organization"),
                    popularRepository: popularRepository,
                    popularRepositorySummary: popularSummary
                ))
            }
            if result.isEmpty {
                guard try document.select("main .blankslate").first() != nil else {
                    throw GitHubTrendingError.schemaMismatch
                }
            }
            return result
        } catch {
            throw .schemaMismatch
        }
    }

    private static func text(in element: Element, selector: String) throws -> String? {
        guard let selected = try element.select(selector).first() else { return nil }
        return trimmed(try selected.text())
    }

    private static func trimmed(_ value: String) -> String? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }

    /// `12,345`、`1.9k`、`2.3M` 这类页面计数；无法识别时返回 nil，而不是 0。
    static func count(_ raw: String?) -> Int? {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(), !value.isEmpty else {
            return nil
        }
        value.removeAll { $0 == "," }
        var multiplier = 1.0
        if value.hasSuffix("k") {
            multiplier = 1_000
            value.removeLast()
        } else if value.hasSuffix("m") {
            multiplier = 1_000_000
            value.removeLast()
        }
        guard !value.isEmpty, value.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }),
              let number = Double(value), number.isFinite, number >= 0, number * multiplier < 1e12 else {
            return nil
        }
        return Int(number * multiplier)
    }

    private static func starsInPeriod(in article: Element) throws -> Int? {
        for span in try article.select("span") {
            let words = try span.text().lowercased().split(whereSeparator: \.isWhitespace)
            guard words.count >= 3, words[1] == "stars" || words[1] == "star",
                  ["today", "this"].contains(String(words[2])) else { continue }
            if let value = count(String(words[0])) { return value }
        }
        return nil
    }

    private static func languageColor(in article: Element) throws -> String? {
        guard let style = try article.select("span.repo-language-color[style]").first()?.attr("style"),
              let range = style.range(of: "#") else { return nil }
        let hex = style[range.upperBound...].prefix { $0.isHexDigit }
        guard hex.count == 6 || hex.count == 3 else { return nil }
        return "#" + hex.uppercased()
    }

    private static func builtBy(in article: Element) throws -> [GitHubTrendingContributor] {
        var result: [GitHubTrendingContributor] = []
        for span in try article.select("span") {
            guard span.ownText().range(of: "Built by", options: .caseInsensitive) != nil else { continue }
            for link in try span.select("a[href]") {
                guard let login = pathComponents(try link.attr("href"), count: 1)?.first,
                      !result.contains(where: { $0.login == login }) else { continue }
                result.append(GitHubTrendingContributor(
                    login: login,
                    avatarURL: avatarURL(try link.select("img[src]").first()?.attr("src"))
                ))
            }
            break
        }
        return result
    }

    private static func metadata(in article: Element, icon: String) throws -> String? {
        guard let parent = try article.select("svg.\(icon)").first()?.parent() else { return nil }
        // 图标自带的无障碍标题不属于取值；优先读页面的截断文本节点。
        if let value = try parent.select(".Truncate-text").first() { return trimmed(try value.text()) }
        return trimmed(parent.ownText())
    }

    /// 头像只接受 GitHub 自有图片域的 HTTPS 地址，避免页面变化把任意外链带进客户端。
    static func avatarURL(_ raw: String?) -> URL? {
        guard let raw, raw.count <= 512, let components = URLComponents(string: raw),
              components.scheme?.lowercased() == "https",
              components.user == nil, components.password == nil, components.port == nil,
              let host = components.host?.lowercased(),
              host == "avatars.githubusercontent.com" || host.hasSuffix(".githubusercontent.com") else {
            return nil
        }
        return components.url
    }

    private static func pathComponents(_ href: String, count: Int) -> [String]? {
        guard href.hasPrefix("/"), !href.hasPrefix("//"),
              let components = URLComponents(string: href),
              components.scheme == nil, components.host == nil,
              components.query == nil, components.fragment == nil else { return nil }
        let path = components.path.split(separator: "/").map(String.init)
        guard path.count == count,
              path.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." && !$0.contains("\\") }) else {
            return nil
        }
        return path
    }
}
