import CryptoKit
import Foundation
import HiIOSStoreCore

/// 将键散列为文件名，避免路径穿越和在文件名中直接暴露原始键。
public actor FileByteStore: ByteStore {
    private let rootDirectory: URL

    public init(rootDirectory: URL) throws(ByteStoreError) {
        guard rootDirectory.isFileURL else { throw .invalidConfiguration }
        self.rootDirectory = rootDirectory
    }

    public func data(for key: StoreKey) async throws(ByteStoreError) -> Data? {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            return try Data(contentsOf: url)
        } catch {
            if (error as NSError).code == NSFileReadNoSuchFileError { return nil }
            throw map(error)
        }
    }

    public func set(_ data: Data, for key: StoreKey) async throws(ByteStoreError) {
        do {
            try FileManager.default.createDirectory(
                at: rootDirectory,
                withIntermediateDirectories: true
            )
            try data.write(to: fileURL(for: key), options: .atomic)
        } catch {
            throw map(error)
        }
    }

    public func removeData(for key: StoreKey) async throws(ByteStoreError) {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            if (error as NSError).code == NSFileNoSuchFileError { return }
            throw map(error)
        }
    }

    private func fileURL(for key: StoreKey) -> URL {
        let digest = SHA256.hash(data: Data(key.rawValue.utf8))
        let filename = digest.map { String(format: "%02x", $0) }.joined() + ".bin"
        return rootDirectory.appendingPathComponent(filename, isDirectory: false)
    }

    private func map(_ error: Error) -> ByteStoreError {
        let nsError = error as NSError
        guard nsError.domain == NSCocoaErrorDomain else { return .unexpected }
        switch nsError.code {
        case NSFileReadNoPermissionError, NSFileWriteNoPermissionError:
            return .permissionDenied
        default:
            return .unexpected
        }
    }
}
