import Foundation

/// 对 URL 结构做通用精确匹配；query 的业务规则由调用方负责。
public struct URLPattern: Hashable, Sendable {
    public let scheme: String
    public let host: String?
    public let path: String
    public let port: Int?
    public let fragment: String?

    public init(
        scheme: String,
        host: String?,
        path: String,
        port: Int?,
        fragment: String?
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.port = port
        self.fragment = fragment
    }

    public func matches(_ url: URL) -> Bool {
        var expectedComponents = URLComponents()
        expectedComponents.path = path
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.user == nil, components.password == nil,
              equalIgnoringCase(components.scheme, scheme),
              equalIgnoringCase(components.host, host),
              components.percentEncodedPath == expectedComponents.percentEncodedPath,
              components.port == port,
              components.fragment == fragment
        else {
            return false
        }
        return true
    }

    private func equalIgnoringCase(_ value: String?, _ expected: String?) -> Bool {
        switch (value, expected) {
        case let (value?, expected?):
            value.caseInsensitiveCompare(expected) == .orderedSame
        case (nil, nil):
            true
        default:
            false
        }
    }
}
