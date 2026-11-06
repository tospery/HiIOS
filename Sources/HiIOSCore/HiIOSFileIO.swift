import Foundation
import HiIOSBase

public enum HiIOSFileError: ClassifiedFailure, Equatable {
    case invalidURL
    case invalidConfiguration
    case missing
    case notDirectory
    case tooLarge
    case permissionDenied
    case unreadable
    case unwritable
    case invalidJSON

    public var category: FailureCategory {
        switch self {
        case .invalidURL, .invalidConfiguration, .notDirectory: .invalidConfiguration
        case .missing, .unreadable, .unwritable: .temporarilyUnavailable
        case .tooLarge, .invalidJSON: .invalidStoredData
        case .permissionDenied: .permissionDenied
        }
    }
}

/// 显式文件 URL 与大小边界；不猜测 Bundle、Documents 或应用容器。
public struct HiIOSFileIO {
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    public func ensureDirectory(at url: URL) throws(HiIOSFileError) {
        guard url.isFileURL else { throw .invalidURL }
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) {
            guard isDirectory.boolValue else { throw .notDirectory }
            return
        }
        do {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        } catch {
            throw Self.mapFileError(error, fallback: .unwritable)
        }
    }

    public func readData(
        at url: URL,
        maximumBytes: Int = 8 * 1_024 * 1_024
    ) throws(HiIOSFileError) -> Data {
        guard url.isFileURL else { throw .invalidURL }
        guard (0..<Int.max).contains(maximumBytes) else { throw .invalidConfiguration }
        let handle: FileHandle
        do {
            handle = try FileHandle(forReadingFrom: url)
        } catch {
            throw Self.mapFileError(error, fallback: .unreadable)
        }
        defer { try? handle.close() }

        var result = Data()
        do {
            while result.count <= maximumBytes {
                let remaining = maximumBytes + 1 - result.count
                let chunk = try handle.read(upToCount: min(remaining, 64 * 1_024)) ?? Data()
                if chunk.isEmpty { return result }
                result.append(chunk)
            }
        } catch {
            throw Self.mapFileError(error, fallback: .unreadable)
        }
        throw .tooLarge
    }

    public func writeDataAtomically(
        _ data: Data,
        to url: URL,
        createParentDirectory: Bool = false
    ) throws(HiIOSFileError) {
        guard url.isFileURL else { throw .invalidURL }
        if createParentDirectory {
            try ensureDirectory(at: url.deletingLastPathComponent())
        }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw Self.mapFileError(error, fallback: .unwritable)
        }
    }

    public func readJSON<Value: Decodable>(
        _ type: Value.Type,
        from url: URL,
        maximumBytes: Int = 8 * 1_024 * 1_024,
        decoder: JSONDecoder = JSONDecoder()
    ) throws(HiIOSFileError) -> Value {
        let data = try readData(at: url, maximumBytes: maximumBytes)
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw .invalidJSON
        }
    }

    public func writeJSON<Value: Encodable>(
        _ value: Value,
        to url: URL,
        encoder: JSONEncoder = JSONEncoder(),
        createParentDirectory: Bool = false
    ) throws(HiIOSFileError) {
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw .invalidJSON
        }
        try writeDataAtomically(data, to: url, createParentDirectory: createParentDirectory)
    }

    private static func mapFileError(_ error: Error, fallback: HiIOSFileError) -> HiIOSFileError {
        let nsError = error as NSError
        guard nsError.domain == NSCocoaErrorDomain else { return fallback }
        switch nsError.code {
        case NSFileReadNoSuchFileError, NSFileNoSuchFileError:
            return .missing
        case NSFileReadNoPermissionError, NSFileWriteNoPermissionError:
            return .permissionDenied
        default:
            return fallback
        }
    }
}
