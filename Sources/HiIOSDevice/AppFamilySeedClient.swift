import Foundation
import HiIOSCore
import HiIOSPersistence

public struct AppFamilySeed: Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let rawValue: UUID

    public var description: String { "<redacted>" }
    public var debugDescription: String { "<redacted>" }

    public init(rawValue: UUID) {
        self.rawValue = rawValue
    }
}

public enum AppFamilySeedError: String, ClassifiedFailure, Equatable {
    case temporarilyUnavailable
    case permissionDenied
    case invalidStoredData
    case invalidConfiguration
    case unexpected

    public var category: FailureCategory {
        FailureCategory(rawValue: rawValue) ?? .unexpected
    }
}

public struct AppFamilySeedClient: Sendable {
    private let item: KeychainItem
    private let store: any KeychainStore
    private let generateUUID: @Sendable () -> UUID

    public init(
        item: KeychainItem,
        store: any KeychainStore,
        generateUUID: @escaping @Sendable () -> UUID = { UUID() }
    ) throws(AppFamilySeedError) {
        guard item.accessGroup != nil else { throw .invalidConfiguration }

        self.item = item
        self.store = store
        self.generateUUID = generateUUID
    }

    public func value() async throws(AppFamilySeedError) -> AppFamilySeed {
        let storedData = try await performKeychainOperation {
            try await store.data(for: item)
        }

        if let storedData {
            return try AppFamilySeed(decoding: storedData)
        }

        let generated = AppFamilySeed(rawValue: generateUUID())
        switch try await performKeychainOperation({
            try await store.insert(generated.encodedData, for: item)
        }) {
        case .inserted:
            return generated
        case .alreadyExists:
            let winningData = try await performKeychainOperation {
                try await store.data(for: item)
            }
            guard let winningData else { throw .unexpected }
            return try AppFamilySeed(decoding: winningData)
        }
    }

    /// 这是影响整个共享 App Family 的显式隐私操作，不用于普通退出登录。
    public func reset() async throws(AppFamilySeedError) {
        try await performKeychainOperation {
            try await store.removeData(for: item)
        }
    }

    private func performKeychainOperation<Value>(
        _ operation: () async throws -> Value
    ) async throws(AppFamilySeedError) -> Value {
        do {
            return try await operation()
        } catch let error as KeychainStoreError {
            throw AppFamilySeedError(error)
        } catch {
            throw .unexpected
        }
    }
}

private extension AppFamilySeedError {
    init(_ error: KeychainStoreError) {
        self = AppFamilySeedError(rawValue: error.category.rawValue) ?? .unexpected
    }
}

private extension AppFamilySeed {
    init(decoding data: Data) throws(AppFamilySeedError) {
        let storedString = String(decoding: data, as: UTF8.self)
        guard let storedUUID = UUID(uuidString: storedString) else {
            throw .invalidStoredData
        }
        self.init(rawValue: storedUUID)
    }

    var encodedData: Data { Data(rawValue.uuidString.utf8) }
}
