import Foundation
@testable import HiIOSPersistence
import Security
import Testing

@Test
func systemKeychainStoreUsesDeviceOnlyNonSynchronizableAttributes() async throws {
    let payload = Data("seed".utf8)
    let item = try sharedItem()
    let recorder = SecurityOperationRecorder(
        copyResult: SecurityCopyResult(status: errSecItemNotFound, value: .none),
        addStatus: errSecSuccess
    )
    let store = SystemKeychainStore(
        operations: recorder.operations
    )

    let insertion = try await store.insert(payload, for: item)
    guard case .inserted = insertion else {
        Issue.record("errSecSuccess 必须映射为 inserted")
        return
    }
    let added = try #require(await recorder.lastAddedQuery())

    #expect(added.item == item)
    #expect(!added.synchronizable)
    #expect(added.accessibility == .afterFirstUnlockThisDeviceOnly)
    #expect(added.valueData == payload)
}

@Test
func systemKeychainStoreBuildsADataOnlyReadQuery() async throws {
    let payload = Data("stored-seed".utf8)
    let item = try sharedItem()
    let recorder = SecurityOperationRecorder(
        copyResult: SecurityCopyResult(status: errSecSuccess, value: .data(payload))
    )
    let store = SystemKeychainStore(operations: recorder.operations)

    let returned = try await store.data(for: item)
    let copied = try #require(await recorder.lastCopiedQuery())

    #expect(returned == payload)
    #expect(copied.item == item)
    #expect(!copied.synchronizable)
    #expect(copied.matchLimitOne)
    #expect(copied.returnsData)
    #expect(copied.accessibility == nil)
    #expect(copied.valueData == nil)
}

@Test
func systemKeychainStoreMapsSecurityReadStatusesToStableErrors() async throws {
    let item = try sharedItem()

    let missing = makeStore(
        copyResult: SecurityCopyResult(status: errSecItemNotFound, value: .none)
    )
    #expect(try await missing.data(for: item) == nil)

    let locked = makeStore(
        copyResult: SecurityCopyResult(status: errSecInteractionNotAllowed, value: .none)
    )
    await #expect(throws: KeychainStoreError.temporarilyUnavailable) {
        try await locked.data(for: item)
    }

    let denied = makeStore(
        copyResult: SecurityCopyResult(status: errSecMissingEntitlement, value: .none)
    )
    await #expect(throws: KeychainStoreError.permissionDenied) {
        try await denied.data(for: item)
    }

    let corrupt = makeStore(
        copyResult: SecurityCopyResult(status: errSecDecode, value: .none)
    )
    await #expect(throws: KeychainStoreError.invalidStoredData) {
        try await corrupt.data(for: item)
    }

    let wrongType = makeStore(
        copyResult: SecurityCopyResult(status: errSecSuccess, value: .invalidType)
    )
    await #expect(throws: KeychainStoreError.invalidStoredData) {
        try await wrongType.data(for: item)
    }
}

@Test
func systemKeychainStoreReturnsAlreadyExistsForDuplicateInsertion() async throws {
    let store = makeStore(addStatus: errSecDuplicateItem)

    let result = try await store.insert(Data("seed".utf8), for: sharedItem())

    guard case .alreadyExists = result else {
        Issue.record("errSecDuplicateItem 必须映射为 alreadyExists")
        return
    }
}

@Test
func systemKeychainStoreMapsInsertionStatusesToStableErrors() async throws {
    let item = try sharedItem()
    let payload = Data("seed".utf8)

    await #expect(throws: KeychainStoreError.temporarilyUnavailable) {
        try await makeStore(addStatus: errSecInteractionNotAllowed).insert(payload, for: item)
    }
    await #expect(throws: KeychainStoreError.permissionDenied) {
        try await makeStore(addStatus: errSecMissingEntitlement).insert(payload, for: item)
    }
    await #expect(throws: KeychainStoreError.invalidStoredData) {
        try await makeStore(addStatus: errSecDecode).insert(payload, for: item)
    }
    await #expect(throws: KeychainStoreError.invalidConfiguration) {
        try await makeStore(addStatus: errSecParam).insert(payload, for: item)
    }
    await #expect(throws: KeychainStoreError.unexpected) {
        try await makeStore(addStatus: errSecInternalError).insert(payload, for: item)
    }
}

@Test
func systemKeychainStoreMapsDeletionStatusesToStableBehavior() async throws {
    let item = try sharedItem()

    try await makeStore(deleteStatus: errSecSuccess).removeData(for: item)
    try await makeStore(deleteStatus: errSecItemNotFound).removeData(for: item)
    await #expect(throws: KeychainStoreError.temporarilyUnavailable) {
        try await makeStore(deleteStatus: errSecNotAvailable).removeData(for: item)
    }
    await #expect(throws: KeychainStoreError.permissionDenied) {
        try await makeStore(deleteStatus: errSecAuthFailed).removeData(for: item)
    }
    await #expect(throws: KeychainStoreError.invalidStoredData) {
        try await makeStore(deleteStatus: errSecDecode).removeData(for: item)
    }
    await #expect(throws: KeychainStoreError.invalidConfiguration) {
        try await makeStore(deleteStatus: errSecParam).removeData(for: item)
    }
    await #expect(throws: KeychainStoreError.unexpected) {
        try await makeStore(deleteStatus: errSecInternalError).removeData(for: item)
    }
}

private func sharedItem() throws -> KeychainItem {
    try KeychainItem(
        service: "com.example.shared",
        account: "app-family-seed",
        accessGroup: "TEAMID.com.example.shared"
    )
}

private func makeStore(copyResult: SecurityCopyResult) -> SystemKeychainStore {
    SystemKeychainStore(
        operations: SecurityOperations(
            copyMatching: { _ in copyResult },
            add: { _ in errSecSuccess },
            delete: { _ in errSecSuccess }
        )
    )
}

private func makeStore(addStatus: OSStatus) -> SystemKeychainStore {
    SystemKeychainStore(
        operations: SecurityOperations(
            copyMatching: { _ in
                SecurityCopyResult(status: errSecItemNotFound, value: .none)
            },
            add: { _ in addStatus },
            delete: { _ in errSecSuccess }
        )
    )
}

private func makeStore(deleteStatus: OSStatus) -> SystemKeychainStore {
    SystemKeychainStore(
        operations: SecurityOperations(
            copyMatching: { _ in
                SecurityCopyResult(status: errSecItemNotFound, value: .none)
            },
            add: { _ in errSecSuccess },
            delete: { _ in deleteStatus }
        )
    )
}

private actor SecurityOperationRecorder {
    private let copyResult: SecurityCopyResult
    private let addStatus: OSStatus
    private var copiedQueries: [SecurityItemQuery] = []
    private var addedQueries: [SecurityItemQuery] = []

    init(
        copyResult: SecurityCopyResult,
        addStatus: OSStatus = errSecSuccess
    ) {
        self.copyResult = copyResult
        self.addStatus = addStatus
    }

    nonisolated var operations: SecurityOperations {
        SecurityOperations(
            copyMatching: { query in await self.copy(query) },
            add: { query in await self.add(query) },
            delete: { _ in errSecSuccess }
        )
    }

    func lastCopiedQuery() -> SecurityItemQuery? {
        copiedQueries.last
    }

    func lastAddedQuery() -> SecurityItemQuery? {
        addedQueries.last
    }

    private func copy(_ query: SecurityItemQuery) -> SecurityCopyResult {
        copiedQueries.append(query)
        return copyResult
    }

    private func add(_ query: SecurityItemQuery) -> OSStatus {
        addedQueries.append(query)
        return addStatus
    }
}
