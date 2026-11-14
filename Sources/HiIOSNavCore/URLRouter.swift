import Foundation

/// 通过结构安全检查的 URL：scheme 小写，host 原样保留，路径按段解码。
///
/// 拒绝 user-info、显式端口（含空端口）、百分号编码或带空白的主机名，以及解码后为空、`.`、`..`，
/// 或含 `/`、`\`、`%`、`?`、`#`、控制字符的路径段（阻止二次解码改变层级）。没有路径时 `pathSegments` 为空。
public struct SanitizedURL: Equatable, Sendable {
    public let scheme: String
    public let host: String
    public let pathSegments: [String]
    /// 没有 query 时为 nil；有 query 时为解码后的各项。
    public let queryItems: [URLQueryItem]?
    /// 原始（未解码）fragment；没有时为 nil。
    public let percentEncodedFragment: String?

    public init?(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased(),
              let host = components.host,
              Self.isValidSegment(host),
              host == host.trimmingCharacters(in: .whitespacesAndNewlines),
              Self.hasPlainAuthority(url, host: host),
              components.user == nil, components.password == nil, components.port == nil,
              let segments = Self.pathSegments(components.percentEncodedPath)
        else { return nil }
        self.scheme = scheme
        self.host = host
        self.pathSegments = segments
        self.queryItems = components.percentEncodedQuery == nil ? nil : (components.queryItems ?? [])
        self.percentEncodedFragment = components.percentEncodedFragment
    }

    /// 路径段的通用约束；调用方可用它校验 host 中携带的标识（如 custom scheme 的用户名）。
    public static func isValidSegment(_ value: String) -> Bool {
        !value.isEmpty && value != "." && value != ".."
            && !value.contains(where: { "/\\%?#".contains($0) })
            && !containsControlCharacters(value)
    }

    public static func containsControlCharacters(_ value: String) -> Bool {
        value.unicodeScalars.contains { CharacterSet.controlCharacters.contains($0) }
    }

    private static func pathSegments(_ encodedPath: String) -> [String]? {
        guard !encodedPath.isEmpty else { return [] }
        guard encodedPath.hasPrefix("/") else { return nil }
        var result: [String] = []
        for rawSegment in encodedPath.dropFirst().split(separator: "/", omittingEmptySubsequences: false) {
            guard !rawSegment.isEmpty,
                  let decoded = String(rawSegment).removingPercentEncoding,
                  isValidSegment(decoded),
                  decoded == decoded.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
            result.append(decoded)
        }
        return result
    }

    /// 比较原始 authority，连空端口与百分号编码的主机名也拒绝。
    private static func hasPlainAuthority(_ url: URL, host: String) -> Bool {
        guard let separator = url.absoluteString.range(of: "://") else { return false }
        let authority = url.absoluteString[separator.upperBound...].prefix { !"/?#".contains($0) }
        return authority == host
    }
}

/// 路由模板的主机部分：精确匹配（不区分大小写）或作为参数取出（如 `atlashub://{login}`）。
public enum URLRouteHost: Hashable, Sendable {
    case exact(String)
    case parameter(String)
}

/// 路由模板的一段路径：字面量（区分大小写）或参数。
public enum URLRouteSegment: Hashable, Sendable {
    case literal(String)
    case parameter(String)
}

/// 一条 URL 路由的结构：scheme、主机与路径模板，以及是否允许 query 与 fragment。
///
/// 路径模板写作 `"/{owner}/{repo}/issues/{number}"`，`{…}` 为参数，空字符串表示没有路径。
public struct URLRouteTemplate: Hashable, Sendable {
    public let scheme: String
    public let host: URLRouteHost
    public let segments: [URLRouteSegment]
    public let allowsQuery: Bool
    public let allowsFragment: Bool

    public init(
        scheme: String,
        host: URLRouteHost,
        path: String = "",
        allowsQuery: Bool = false,
        allowsFragment: Bool = false
    ) {
        self.scheme = scheme.lowercased()
        self.host = host
        self.segments = path.split(separator: "/").map { raw in
            raw.hasPrefix("{") && raw.hasSuffix("}")
                ? .parameter(String(raw.dropFirst().dropLast())) : .literal(String(raw))
        }
        self.allowsQuery = allowsQuery
        self.allowsFragment = allowsFragment
    }

    /// 结构匹配成功时返回取出的参数（主机参数与路径参数）。
    public func match(_ url: SanitizedURL) -> URLRouteMatch? {
        guard url.scheme == scheme,
              allowsQuery || url.queryItems == nil,
              allowsFragment || url.percentEncodedFragment == nil,
              url.pathSegments.count == segments.count else { return nil }
        var parameters: [String: String] = [:]
        switch host {
        case .exact(let expected):
            guard url.host.caseInsensitiveCompare(expected) == .orderedSame else { return nil }
        case .parameter(let name):
            parameters[name] = url.host
        }
        for (segment, value) in zip(segments, url.pathSegments) {
            switch segment {
            case .literal(let literal):
                guard value == literal else { return nil }
            case .parameter(let name):
                parameters[name] = value
            }
        }
        return URLRouteMatch(url: url, parameters: parameters)
    }
}

/// 模板匹配结果；业务校验（保留名、数字范围、query 规则）在路由规则的 `resolve` 中完成。
public struct URLRouteMatch: Equatable, Sendable {
    public let url: SanitizedURL
    public let parameters: [String: String]

    public init(url: SanitizedURL, parameters: [String: String]) {
        self.url = url
        self.parameters = parameters
    }

    public subscript(_ name: String) -> String? { parameters[name] }
}

/// 一条路由规则：模板、可达的入口上下文与把匹配结果转成项目路由的函数（返回 nil 表示拒绝）。
public struct URLRouteRule<Context: Hashable & Sendable, Route: Sendable>: Sendable {
    public let template: URLRouteTemplate
    public let contexts: Set<Context>
    public let resolve: @Sendable (URLRouteMatch) -> Route?

    public init(
        _ template: URLRouteTemplate,
        contexts: Set<Context>,
        resolve: @escaping @Sendable (URLRouteMatch) -> Route?
    ) {
        self.template = template
        self.contexts = contexts
        self.resolve = resolve
    }
}

/// 按入口上下文区分可达范围的 URL 路由表：先做结构安全检查，再按规则顺序取第一个成功的路由。
///
/// 上下文由项目定义（如外部入口与 App 内导航），同一 URL 在不同上下文中的可达范围可以不同；
/// 路由表不持有导航状态，只负责“URL → 强类型路由”。
public struct URLRouter<Context: Hashable & Sendable, Route: Sendable>: Sendable {
    public let rules: [URLRouteRule<Context, Route>]

    public init(rules: [URLRouteRule<Context, Route>]) {
        self.rules = rules
    }

    public func route(_ url: URL, context: Context) -> Route? {
        guard let sanitized = SanitizedURL(url) else { return nil }
        for rule in rules where rule.contexts.contains(context) {
            if let match = rule.template.match(sanitized), let route = rule.resolve(match) {
                return route
            }
        }
        return nil
    }
}
