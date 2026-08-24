import Foundation

/// 跨系统实现保持稳定的失败分类，调用方不需要理解底层错误码。
public enum FailureCategory: String, Error, Sendable {
    case temporarilyUnavailable
    case permissionDenied
    case invalidStoredData
    case invalidConfiguration
    case unexpected
}

/// 让上层只依赖稳定分类，而不是平台或第三方错误表示。
public protocol ClassifiedFailure: Error, Sendable {
    var category: FailureCategory { get }
}
