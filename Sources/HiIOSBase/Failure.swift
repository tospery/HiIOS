/// 跨实现共享的失败分类，不暴露平台或第三方错误码。
public enum FailureCategory: String, Error, Sendable {
    case temporarilyUnavailable
    case permissionDenied
    case invalidStoredData
    case invalidConfiguration
    case unexpected
}

public protocol ClassifiedFailure: Error, Sendable {
    var category: FailureCategory { get }
}
