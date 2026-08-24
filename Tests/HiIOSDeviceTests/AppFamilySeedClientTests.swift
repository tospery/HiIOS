import Foundation
import HiIOSDevice
import HiIOSPersistence
import Testing

@Test
func existingAppFamilySeedIsReturnedWithoutInsertion() async throws {
    let existing = try #require(
        UUID(uuidString: "11111111-2222-3333-4444-555555555555")
    )
    let store = ScriptedKeychainStore(
        reads: [.success(Data(existing.uuidString.utf8))],
        insertions: [.failure(.unexpected)]
    )
    let client = try AppFamilySeedClient(
        item: try sharedSeedItem(),
        store: store,
        generateUUID: { UUID() }
    )

    let seed = try await client.value()

    #expect(seed.rawValue == existing)
}

@Test
func missingAppFamilySeedIsGeneratedOnceAndPersisted() async throws {
    let generated = try #require(
        UUID(uuidString: "AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE")
    )
    let laterCandidate = try #require(
        UUID(uuidString: "99999999-8888-4777-8666-555555555555")
    )
    let item = try sharedSeedItem()
    let store = InMemoryKeychainStore()
    let firstClient = try AppFamilySeedClient(
        item: item,
        store: store,
        generateUUID: { generated }
    )

    let first = try await firstClient.value()
    let second = try await AppFamilySeedClient(
        item: item,
        store: store,
        generateUUID: { laterCandidate }
    ).value()

    #expect(first.rawValue == generated)
    #expect(second == first)
}

@Test
func duplicateInsertionRaceReturnsTheWinningAppFamilySeed() async throws {
    let candidate = try #require(
        UUID(uuidString: "AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE")
    )
    let winner = try #require(
        UUID(uuidString: "11111111-2222-4333-8444-555555555555")
    )
    let store = ScriptedKeychainStore(
        reads: [
            .success(nil),
            .success(Data(winner.uuidString.utf8))
        ],
        insertions: [.success(.alreadyExists)]
    )
    let client = try AppFamilySeedClient(
        item: try sharedSeedItem(),
        store: store,
        generateUUID: { candidate }
    )

    let seed = try await client.value()

    #expect(seed.rawValue == winner)
}

@Test
func explicitResetAllowsANewAppFamilySeed() async throws {
    let firstUUID = try #require(
        UUID(uuidString: "AAAAAAAA-BBBB-4CCC-8DDD-EEEEEEEEEEEE")
    )
    let replacementUUID = try #require(
        UUID(uuidString: "11111111-2222-4333-8444-555555555555")
    )
    let item = try sharedSeedItem()
    let store = InMemoryKeychainStore()
    let original = try AppFamilySeedClient(
        item: item,
        store: store,
        generateUUID: { firstUUID }
    )
    _ = try await original.value()

    try await original.reset()
    let replacement = try await AppFamilySeedClient(
        item: item,
        store: store,
        generateUUID: { replacementUUID }
    ).value()

    #expect(replacement.rawValue == replacementUUID)
}

@Test
func temporarilyUnavailableKeychainDoesNotRotateTheSeed() async throws {
    let store = ScriptedKeychainStore(
        reads: [.failure(.temporarilyUnavailable)]
    )
    let client = try AppFamilySeedClient(
        item: try sharedSeedItem(),
        store: store,
        generateUUID: {
            Issue.record("暂不可用时不应生成新的 App Family 身份")
            return UUID()
        }
    )

    await #expect(throws: AppFamilySeedError.temporarilyUnavailable) {
        try await client.value()
    }
}

@Test
func malformedStoredValueIsRejectedWithoutRotation() async throws {
    let store = ScriptedKeychainStore(
        reads: [.success(Data("not-a-uuid".utf8))]
    )
    let client = try AppFamilySeedClient(
        item: try sharedSeedItem(),
        store: store,
        generateUUID: {
            Issue.record("损坏数据不得被静默轮换")
            return UUID()
        }
    )

    await #expect(throws: AppFamilySeedError.invalidStoredData) {
        try await client.value()
    }
}

@Test
func appFamilySeedRequiresASharedAccessGroup() throws {
    let unsharedItem = try KeychainItem(
        service: "com.example.app",
        account: "app-family-seed"
    )

    #expect(throws: AppFamilySeedError.invalidConfiguration) {
        try AppFamilySeedClient(
            item: unsharedItem,
            store: InMemoryKeychainStore()
        )
    }
}

private func sharedSeedItem() throws -> KeychainItem {
    try KeychainItem(
        service: "com.example.shared",
        account: "app-family-seed",
        accessGroup: "TEAMID.com.example.shared"
    )
}

private actor ScriptedKeychainStore: KeychainStore {
    private var reads: [Result<Data?, KeychainStoreError>]
    private var insertions: [Result<KeychainInsertionResult, KeychainStoreError>]

    init(
        reads: [Result<Data?, KeychainStoreError>],
        insertions: [Result<KeychainInsertionResult, KeychainStoreError>] = []
    ) {
        self.reads = reads
        self.insertions = insertions
    }

    func data(for item: KeychainItem) async throws(KeychainStoreError) -> Data? {
        try next(&reads).get()
    }

    func insert(
        _ data: Data,
        for item: KeychainItem
    ) async throws(KeychainStoreError) -> KeychainInsertionResult {
        try next(&insertions).get()
    }

    func removeData(for item: KeychainItem) async throws(KeychainStoreError) {}

    private func next<Value>(
        _ values: inout [Result<Value, KeychainStoreError>]
    ) throws(KeychainStoreError) -> Result<Value, KeychainStoreError> {
        guard !values.isEmpty else { throw .unexpected }
        return values.removeFirst()
    }
}

private actor InMemoryKeychainStore: KeychainStore {
    private var values: [KeychainItem: Data] = [:]

    func data(for item: KeychainItem) async throws(KeychainStoreError) -> Data? {
        values[item]
    }

    func insert(
        _ data: Data,
        for item: KeychainItem
    ) async throws(KeychainStoreError) -> KeychainInsertionResult {
        guard values[item] == nil else { return .alreadyExists }
        values[item] = data
        return .inserted
    }

    func removeData(for item: KeychainItem) async throws(KeychainStoreError) {
        values[item] = nil
    }
}
