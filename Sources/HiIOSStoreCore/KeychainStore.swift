import Foundation
import HiIOSBase

public enum KeychainStoreError: String, ClassifiedFailure, Equatable {
    case temporarilyUnavailable
    case permissionDenied
    case invalidStoredData
    case invalidConfiguration
    case unexpected

    public var category: FailureCategory {
        FailureCategory(rawValue: rawValue) ?? .unexpected
    }
}

public struct KeychainItem: Hashable, Sendable {
    public let service: String
    public let account: String
    public let accessGroup: String?

    public init(
        service: String,
        account: String,
        accessGroup: String? = nil
    ) throws(KeychainStoreError) {
        let whitespace = CharacterSet.whitespacesAndNewlines
        guard !service.trimmingCharacters(in: whitespace).isEmpty,
              !account.trimmingCharacters(in: whitespace).isEmpty,
              accessGroup.map({ !$0.trimmingCharacters(in: whitespace).isEmpty }) ?? true else {
            throw .invalidConfiguration
        }
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
    }
}

public enum KeychainInsertionResult: Equatable, Sendable {
    case inserted
    case alreadyExists
}

/// 原始字节 Keychain 契约；Security 状态码在实现模块内转换。
public protocol KeychainStore: Sendable {
    func data(for item: KeychainItem) async throws(KeychainStoreError) -> Data?
    func insert(_ data: Data, for item: KeychainItem) async throws(KeychainStoreError) -> KeychainInsertionResult
    // SwiftLint 0.55 将无返回值 typed throws 后的类型误判为变量名。
    // swiftlint:disable:next identifier_name
    func removeData(for item: KeychainItem) async throws(KeychainStoreError)
}
