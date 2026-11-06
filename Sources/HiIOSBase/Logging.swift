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

/// 输出端只能收到策略处理后的记录；构造器不对外开放。
public struct RedactedLogRecord: Equatable, Sendable {
    public let level: LogLevel
    public let event: String
    public let message: String
    public let metadata: [String: String]
}

public enum LogRedactionPolicy: Sendable {
    case release
    case diagnostic

    public func allows(_ level: LogLevel) -> Bool {
        switch (self, level) {
        case (.release, .verbose), (.release, .debug): false
        default: true
        }
    }

    public func redact(_ record: LogRecord) -> RedactedLogRecord {
        let metadata = record.metadata.reduce(into: [String: String]()) { result, entry in
            let key = Self.redactText(entry.key)
            result[key] = Self.isSensitiveKey(entry.key)
                ? "<redacted>" : Self.redactText(entry.value)
        }
        return RedactedLogRecord(
            level: record.level,
            event: Self.redactText(record.event),
            message: Self.redactText(record.message),
            metadata: metadata
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
    func write(_ record: RedactedLogRecord)
}

/// sink 只通过注入获取；没有隐式全局日志目的地。
public struct LogClient: Sendable {
    private let sink: any LogSink
    private let policy: LogRedactionPolicy

    public init(sink: any LogSink, policy: LogRedactionPolicy = .release) {
        self.sink = sink
        self.policy = policy
    }

    @discardableResult
    public func log(_ record: LogRecord) -> LogDisposition {
        guard policy.allows(record.level) else { return .filtered }
        sink.write(policy.redact(record))
        return .emitted
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
