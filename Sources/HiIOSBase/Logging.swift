import Foundation

public enum LogLevel: Int, CaseIterable, Sendable {
    case verbose
    case debug
    case info
    case warning
    case error
}

public enum LogDisposition: Sendable {
    case emitted
    case filtered
}

/// 输入记录可能含敏感内容，只能经 LogClient 交给输出端。
public struct LogRecord: Equatable, Sendable {
    public let level: LogLevel
    public let event: String
    public let message: String
    public let metadata: [String: String]

    public init(
        level: LogLevel,
        event: String,
        message: String = "",
        metadata: [String: String] = [:]
    ) {
        self.level = level
        self.event = event
        self.message = message
        self.metadata = metadata
    }
}

/// 输出端只能收到经 `LogRedactionPolicy` 处理后的记录；构造器不对外开放。
/// `isRedacted` 为 false 表示消费项目显式选择了 `.unredacted`，内容可能含凭据与正文。
public struct LogOutputRecord: Equatable, Sendable {
    public let level: LogLevel
    public let event: String
    public let message: String
    public let metadata: [String: String]
    public let isRedacted: Bool
}

/// 默认脱敏。`.unredacted` 原样传递，只有消费项目明确保护输出端（例如加密存储或受控的开发诊断）
/// 时才应选择；本库不判断渠道或环境。
public enum LogRedactionPolicy: Sendable {
    case release
    case diagnostic
    case unredacted

    public func allows(_ level: LogLevel) -> Bool {
        switch (self, level) {
        case (.release, .verbose), (.release, .debug): false
        default: true
        }
    }

    public func redact(_ record: LogRecord) -> LogOutputRecord {
        if case .unredacted = self {
            return LogOutputRecord(
                level: record.level,
                event: record.event,
                message: record.message,
                metadata: record.metadata,
                isRedacted: false
            )
        }
        let metadata = record.metadata.reduce(into: [String: String]()) { result, entry in
            let key = Self.redactText(entry.key)
            result[key] = Self.isSensitiveKey(entry.key)
                ? "<redacted>" : Self.redactText(entry.value)
        }
        return LogOutputRecord(
            level: record.level,
            event: Self.redactText(record.event),
            message: Self.redactText(record.message),
            metadata: metadata,
            isRedacted: true
        )
    }

    private static func isSensitiveKey(_ key: String) -> Bool {
        let normalized = key.lowercased().filter { $0.isLetter || $0.isNumber }
        let sensitiveTerms = [
            "authorization", "cookie", "password", "passcode", "verificationcode",
            "otp", "token", "secret", "apikey", "privatekey", "pkce", "codeverifier",
            "oauthcode", "oauthstate", "session", "appfamilyseed", "deviceid",
            "requestbody", "responsebody", "body", "location"
        ]
        return sensitiveTerms.contains { normalized.contains($0) }
    }

    private static func redactText(_ text: String) -> String {
        let credentialPattern =
            #"(?i)(\b(?:access[_-]?token|refresh[_-]?token|provider[_-]?token|password|passcode|"#
            + #"verification[_-]?code|otp|pkce[_-]?verifier|code[_-]?verifier|oauth[_-]?(?:code|state)|"#
            + #"session|cookie|app[_-]?family[_-]?seed|device[_-]?id|api[_-]?key|secret)\b\s*[:=]\s*)"#
            + #"(?:\"[^\"\r\n]*\"|'[^'\r\n]*'|[^\s,;&]+)"#
        let replacements: [(pattern: String, template: String)] = [
            (#"(?im)\b(authorization|cookie|set-cookie)\s*:\s*[^\r\n]+"#, "$1: <redacted>"),
            (#"(?im)\b(request[_-]?body|response[_-]?body|body)\s*[:=]\s*[^\r\n]+"#, "$1=<redacted>"),
            (#"(?i)((?:[a-z][a-z0-9+.-]*://|/)[^\s?]*)\?[^\s]+"#, "$1?<redacted>"),
            (#"(?i)(\b(?:code|state)\s*=\s*)[^&\s,;]+"#, "$1<redacted>"),
            (#"(?i)\b[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\b"#, "<redacted>"),
            (credentialPattern, "$1<redacted>"),
            (#"(?i)\b(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+"#, "$1 <redacted>")
        ]

        return replacements.reduce(text) { value, replacement in
            guard let expression = try? NSRegularExpression(pattern: replacement.pattern) else {
                // 规则失效时不允许将原文继续交给输出端。
                return "<redacted>"
            }
            let range = NSRange(value.startIndex..<value.endIndex, in: value)
            return expression.stringByReplacingMatches(
                in: value, range: range, withTemplate: replacement.template
            )
        }
    }
}

public protocol LogSink: Sendable {
    func write(_ record: LogOutputRecord)
}

/// 一个输出端及其独立的级别与脱敏策略。
public struct LogRoute: Sendable {
    public let sink: any LogSink
    public let policy: LogRedactionPolicy

    public init(sink: any LogSink, policy: LogRedactionPolicy = .release) {
        self.sink = sink
        self.policy = policy
    }
}

/// sink 只通过注入获取；没有隐式全局日志目的地。每条路由各自过滤与脱敏，互不影响。
public struct LogClient: Sendable {
    private let routes: [LogRoute]

    public init(routes: [LogRoute]) {
        self.routes = routes
    }

    public init(sink: any LogSink, policy: LogRedactionPolicy = .release) {
        self.init(routes: [LogRoute(sink: sink, policy: policy)])
    }

    @discardableResult
    public func log(_ record: LogRecord) -> LogDisposition {
        var disposition = LogDisposition.filtered
        for route in routes where route.policy.allows(record.level) {
            route.sink.write(route.policy.redact(record))
            disposition = .emitted
        }
        return disposition
    }

    @discardableResult
    public func log(
        _ level: LogLevel,
        event: String,
        message: String = "",
        metadata: [String: String] = [:]
    ) -> LogDisposition {
        log(LogRecord(level: level, event: event, message: message, metadata: metadata))
    }
}
