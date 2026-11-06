import Foundation
import HiIOSBase
import SwiftyBeaver

/// 调用方显式注入并独占目的地；不会修改 SwiftyBeaver 的全局目的地集合。
/// BaseDestination 不声明 Sendable，本类仅在锁内调用它且不向外返回引用。
/// 直接调用 destination，因此保留 minLevel，但不会执行 SDK 全局分发路径中的自定义 filters。
public final class SwiftyBeaverLogSink: LogSink, @unchecked Sendable {
    private let destination: BaseDestination
    private let minimumLevel: LogLevel
    private let lock = NSLock()

    /// 传入后不应由其他代码并发使用或修改同一 destination。
    public init(destination: BaseDestination, minimumLevel: LogLevel = .verbose) {
        self.destination = destination
        self.minimumLevel = minimumLevel
    }

    public func write(_ record: RedactedLogRecord) {
        guard record.level.rawValue >= minimumLevel.rawValue else { return }
        let level = record.level.swiftyBeaverLevel
        let metadata = record.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        let message = "event=\(record.event) message=\(record.message) metadata=\(metadata)"

        lock.lock()
        defer { lock.unlock() }
        guard level.rawValue >= destination.minLevel.rawValue else { return }
        _ = destination.send(
            level,
            msg: message,
            thread: "",
            file: "",
            function: "",
            line: 0,
            context: nil
        )
    }
}

private extension LogLevel {
    var swiftyBeaverLevel: SwiftyBeaver.Level {
        switch self {
        case .verbose: .verbose
        case .debug: .debug
        case .info: .info
        case .warning: .warning
        case .error: .error
        }
    }
}
