import Foundation

public enum ShareContent: Equatable, Sendable {
    case text(String)
    case link(URL)
    case image(data: Data, mediaType: String)
}

/// 每个 ShareClient 实例由装配层配置其目标服务。
public struct ShareRequest: Equatable, Sendable {
    public let content: ShareContent
    public let title: String?

    public init(content: ShareContent, title: String? = nil) {
        self.content = content
        self.title = title
    }
}

public enum ShareResult: Equatable, Sendable {
    case completed
    case cancelled
    case failed(FailureCategory)
}

public protocol ShareClient: Sendable {
    func share(_ request: ShareRequest) async -> ShareResult
}
