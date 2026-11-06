/// 统计属性只接受可安全跨并发边界传递的标量。
public enum AnalyticsValue: Equatable, Sendable {
    case string(String)
    case integer(Int)
    case double(Double)
    case boolean(Bool)
}

public struct AnalyticsEvent: Equatable, Sendable {
    public let name: String
    public let parameters: [String: AnalyticsValue]

    public init(name: String, parameters: [String: AnalyticsValue] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

/// SDK 适配器自行决定如何映射事件名和属性，不让 SDK 类型进入契约。
public protocol AnalyticsSink: Sendable {
    func track(_ event: AnalyticsEvent) async
}
