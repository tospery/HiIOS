import Foundation
import os

public enum LogLevel: Sendable {
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

public struct LogRecord: Equatable, Sendable {
    public let event: String
    public let message: String
    public let metadata: [String: String]

    public init(
        event: String,
        message: String = "",
        metadata: [String: String] = [:]
    ) {
        self.event = event
        self.message = message
        self.metadata = metadata
    }
}

public enum RedactionPolicy: Sendable {
    case release
    case diagnostic

    public func allows(_ level: LogLevel) -> Bool {
        switch (self, level) {
        case (.release, .verbose), (.release, .debug):
            false
        default:
            true
        }
    }

    public func redact(_ record: LogRecord) -> LogRecord {
        return LogRecord(
            event: Self.redactText(record.event),
            message: Self.redactText(record.message),
            metadata: record.metadata.reduce(into: [:]) { result, entry in
                result[entry.key] = Self.isSensitive(entry.key)
                    ? "<redacted>"
                    : Self.redactText(entry.value)
            }
        )
    }

    private static func isSensitive(_ key: String) -> Bool {
        let normalized = key
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
        let sensitiveTerms = [
            "authorization",
            "cookie",
            "password",
            "passcode",
            "verificationcode",
            "otp",
            "token",
            "pkce",
            "codeverifier",
            "oauthcode",
            "oauthstate",
            "session",
            "appfamilyseed",
            "deviceid",
            "requestbody",
            "responsebody",
            "body",
            "location"
        ]
        return sensitiveTerms.contains { normalized.contains($0) }
    }

    private static func redactText(_ text: String) -> String {
        let credentialPattern =
            #"(?i)(\b(?:access[_-]?token|refresh[_-]?token|provider[_-]?token|password|passcode|"#
            + #"verification[_-]?code|otp|pkce[_-]?verifier|code[_-]?verifier|oauth[_-]?(?:code|state)|"#
            + #"session|cookie|app[_-]?family[_-]?seed|device[_-]?id)\b\s*[:=]\s*)"#
            + #"(?:\"[^\"\r\n]*\"|'[^'\r\n]*'|[^\s,;&]+)"#
        let replacements = [
            (
                #"(?im)\b(authorization|cookie|set-cookie)\s*:\s*[^\r\n]+"#,
                "$1: <redacted>"
            ),
            (
                #"(?im)\b(request[_-]?body|response[_-]?body|body)\s*[:=]\s*[^\r\n]+"#,
                "$1=<redacted>"
            ),
            (
                #"(?i)((?:[a-z][a-z0-9+.-]*://|/)[^\s?]*)\?[^\s]+"#,
                "$1?<redacted>"
            ),
            (
                #"(?i)(\b(?:code|state)\s*=\s*)[^&\s,;]+"#,
                "$1<redacted>"
            ),
            (
                #"(?i)\b[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\b"#,
                "<redacted>"
            ),
            (
                credentialPattern,
                "$1<redacted>"
            ),
            (
                #"(?i)\b(Bearer|Basic)\s+[A-Za-z0-9._~+/=-]+"#,
                "$1 <redacted>"
            )
        ]

        return replacements.reduce(text) { value, replacement in
            guard let expression = try? NSRegularExpression(
                pattern: replacement.0
            ) else {
                // Release 脱敏规则失效时宁可隐藏整段，也不回退到原始敏感内容。
                return "<redacted>"
            }
            let range = NSRange(value.startIndex..<value.endIndex, in: value)
            return expression.stringByReplacingMatches(
                in: value,
                range: range,
                withTemplate: replacement.1
            )
        }
    }
}

/// Apple Logger 的窄封装；接口不暴露 OSLog 类型或全局 logger。
public struct Logger: Sendable {
    private let subsystem: String
    private let category: String
    private let policy: RedactionPolicy

    public init(
        subsystem: String,
        category: String,
        policy: RedactionPolicy = .release
    ) {
        self.subsystem = subsystem
        self.category = category
        self.policy = policy
    }

    @discardableResult
    public func log(
        _ level: LogLevel,
        event: String,
        message: String = "",
        metadata: [String: String] = [:]
    ) -> LogDisposition {
        guard policy.allows(level) else { return .filtered }

        let record = policy.redact(
            LogRecord(event: event, message: message, metadata: metadata)
        )
        let metadataDescription = record.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        if #available(macOS 11.0, iOS 14.0, *) {
            let appleLogger = os.Logger(subsystem: subsystem, category: category)
            appleLogger.log(
                level: level.osLogType,
                """
                event=\(record.event, privacy: .private)
                message=\(record.message, privacy: .private)
                metadata=\(metadataDescription, privacy: .private)
                """
            )
            return .emitted
        } else {
            // HiIOS 4.x 仅支持 iOS 17+；分支只让 SwiftPM 主机测试可编译。
            return .filtered
        }
    }
}

private extension LogLevel {
    var osLogType: OSLogType {
        switch self {
        case .verbose, .debug:
            .debug
        case .info:
            .info
        case .warning:
            .default
        case .error:
            .error
        }
    }
}
