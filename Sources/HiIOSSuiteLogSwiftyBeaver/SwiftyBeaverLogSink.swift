import Foundation
import HiIOSBase
import SwiftyBeaver

/// 调用方显式注入并独占目的地；不会修改 SwiftyBeaver 的全局目的地集合。
/// BaseDestination 不声明 Sendable，本类仅在锁内调用它且不向外返回引用。
/// 直接调用 destination，因此保留 minLevel，但不会执行 SDK 全局分发路径中的自定义 filters。
///
/// 每次 `send` 的 `context` 是完整的 `LogOutputRecord`：自定义目的地可据此取回结构化字段，
/// 内置目的地（如 `ConsoleDestination`）使用可读的 `msg`。
public final class SwiftyBeaverLogSink: LogSink, @unchecked Sendable {
    private let destinations: [BaseDestination]
    private let minimumLevel: LogLevel
    private let lock = NSLock()

    /// 传入后不应由其他代码并发使用或修改这些 destination。
    public init(destinations: [BaseDestination], minimumLevel: LogLevel = .verbose) {
        self.destinations = destinations
        self.minimumLevel = minimumLevel
    }

    public convenience init(destination: BaseDestination, minimumLevel: LogLevel = .verbose) {
        self.init(destinations: [destination], minimumLevel: minimumLevel)
    }

    public func write(_ record: LogOutputRecord) {
        guard record.level.rawValue >= minimumLevel.rawValue else { return }
        let level = record.level.swiftyBeaverLevel
        let metadata = record.metadata
            .sorted { $0.key < $1.key }
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: " ")
        let message = "event=\(record.event) message=\(record.message) metadata=\(metadata)"

        lock.lock()
        defer { lock.unlock() }
        for destination in destinations where level.rawValue >= destination.minLevel.rawValue {
            _ = destination.send(
                level,
                msg: message,
                thread: "",
                file: "",
                function: "",
                line: 0,
                context: record
            )
        }
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
