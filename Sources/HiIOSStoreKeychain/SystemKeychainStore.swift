import Foundation
import HiIOSStoreCore
import Security

enum SecurityAccessibility: Sendable {
    case afterFirstUnlockThisDeviceOnly
}

struct SecurityItemQuery: Equatable, Sendable {
    let item: KeychainItem
    var synchronizable = false
    var matchLimitOne = false
    var returnsData = false
    var accessibility: SecurityAccessibility?
    var valueData: Data?

    var dictionary: [CFString: Any] {
        var result: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: item.service,
            kSecAttrAccount: item.account,
            kSecAttrSynchronizable: synchronizable ? kCFBooleanTrue as Any : kCFBooleanFalse as Any
        ]
        if let accessGroup = item.accessGroup {
            result[kSecAttrAccessGroup] = accessGroup
        }
        if matchLimitOne {
            result[kSecMatchLimit] = kSecMatchLimitOne
        }
        if returnsData {
            result[kSecReturnData] = kCFBooleanTrue
        }
        if accessibility == .afterFirstUnlockThisDeviceOnly {
            result[kSecAttrAccessible] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
        if let valueData {
            result[kSecValueData] = valueData
        }
        return result
    }
}

enum SecurityCopyValue: Equatable, Sendable {
    case none
    case data(Data)
    case invalidType
}

struct SecurityCopyResult: Sendable {
    let status: OSStatus
    let value: SecurityCopyValue
}

struct SecurityOperations: Sendable {
    let copyMatching: @Sendable (SecurityItemQuery) async -> SecurityCopyResult
    let add: @Sendable (SecurityItemQuery) async -> OSStatus
    let delete: @Sendable (SecurityItemQuery) async -> OSStatus

    static let system = SecurityOperations(
        copyMatching: { query in
            var value: CFTypeRef?
            let status = SecItemCopyMatching(query.dictionary as CFDictionary, &value)
            let copyValue: SecurityCopyValue
            if let data = value as? Data {
                copyValue = .data(data)
            } else if value == nil {
                copyValue = .none
            } else {
                copyValue = .invalidType
            }
            return SecurityCopyResult(status: status, value: copyValue)
        },
        add: { query in
            SecItemAdd(query.dictionary as CFDictionary, nil)
        },
        delete: { query in
            SecItemDelete(query.dictionary as CFDictionary)
        }
    )
}

/// 使用 Generic Password 项目的系统 Keychain adapter。
public struct SystemKeychainStore: KeychainStore {
    private let operations: SecurityOperations

    public init() {
        operations = .system
    }

    init(operations: SecurityOperations) {
        self.operations = operations
    }

    public func data(for item: KeychainItem) async throws(KeychainStoreError) -> Data? {
        var query = SecurityItemQuery(item: item)
        query.matchLimitOne = true
        query.returnsData = true

        let result = await operations.copyMatching(query)
        switch result.status {
        case errSecSuccess:
            guard case let .data(data) = result.value else { throw .invalidStoredData }
            return data
        case errSecItemNotFound:
            return nil
        default:
            throw map(result.status)
        }
    }

    public func insert(
        _ data: Data,
        for item: KeychainItem
    ) async throws(KeychainStoreError) -> KeychainInsertionResult {
        var query = SecurityItemQuery(item: item)
        query.accessibility = .afterFirstUnlockThisDeviceOnly
        query.valueData = data

        switch await operations.add(query) {
        case errSecSuccess:
            return .inserted
        case errSecDuplicateItem:
            return .alreadyExists
        case let status:
            throw map(status)
        }
    }

    public func removeData(for item: KeychainItem) async throws(KeychainStoreError) {
        switch await operations.delete(SecurityItemQuery(item: item)) {
        case errSecSuccess, errSecItemNotFound:
            return
        case let status:
            throw map(status)
        }
    }

    private func map(_ status: OSStatus) -> KeychainStoreError {
        switch status {
        case errSecInteractionNotAllowed, errSecNotAvailable:
            .temporarilyUnavailable
        case errSecMissingEntitlement, errSecAuthFailed, errSecUserCanceled:
            .permissionDenied
        case errSecDecode:
            .invalidStoredData
        case errSecParam:
            .invalidConfiguration
        default:
            .unexpected
        }
    }
}
