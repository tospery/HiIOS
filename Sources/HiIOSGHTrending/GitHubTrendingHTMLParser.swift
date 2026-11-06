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
                    stars: try Self.text(in: article, selector: "a[href$=\"/stargazers\"]"),
                    forks: try Self.text(in: article, selector: "a[href$=\"/forks\"]"),
                    starsInPeriod: try Self.text(in: article, selector: "span.float-sm-right")
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
                guard let link = try article.select("h1 a[href], h2 a[href]").first(),
                      let identity = Self.pathComponents(try link.attr("href"), count: 1) else {
                    throw GitHubTrendingError.schemaMismatch
                }
                let popularLink = try article.select("h2 a[href]").first()
                let popularRepository: String?
                if let popularLink, popularLink !== link {
                    guard let reference = Self.pathComponents(try popularLink.attr("href"), count: 2) else {
                        throw GitHubTrendingError.schemaMismatch
                    }
                    popularRepository = reference.joined(separator: "/")
                } else {
                    popularRepository = nil
                }
                result.append(GitHubTrendingDeveloper(
                    rank: result.count + 1,
                    login: identity[0],
                    displayName: try Self.text(in: article, selector: "h1"),
                    popularRepository: popularRepository,
                    summary: try Self.text(in: article, selector: "p")
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
        let value = try selected.text().trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
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
