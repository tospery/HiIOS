import HiIOSBase
import os

/// Apple unified logging 的显式目的地；只接收 Base 已脱敏的记录。
public struct OSLogSink: LogSink {
    private let subsystem: String
    private let category: String

    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }

    public func write(_ record: RedactedLogRecord) {
        let metadata = record.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        let logger = os.Logger(subsystem: subsystem, category: category)
        logger.log(
            level: record.level.osLogType,
            """
            event=\(record.event, privacy: .private)
            message=\(record.message, privacy: .private)
            metadata=\(metadata, privacy: .private)
            """
        )
    }
}

private extension LogLevel {
    var osLogType: OSLogType {
        switch self {
        case .verbose, .debug: .debug
        case .info: .info
        case .warning: .default
        case .error: .error
        }
    }
}
