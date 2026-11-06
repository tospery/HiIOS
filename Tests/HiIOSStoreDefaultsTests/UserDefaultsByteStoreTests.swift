import Foundation
import HiIOSStoreCore
import HiIOSStoreDefaults
import Testing

@Test
func userDefaultsStoreKeepsNamespaceAndRejectsUnexpectedValueType() async throws {
    let suiteName = "hiios.store.tests.\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defer { defaults.removePersistentDomain(forName: suiteName) }
    let store = try UserDefaultsByteStore(suiteName: suiteName, namespace: "preferences")
    let key = try StoreKey("theme")
    let payload = Data("dark".utf8)

    #expect(try await store.data(for: key) == nil)
    try await store.set(payload, for: key)
    #expect(try await store.data(for: key) == payload)
    #expect(defaults.object(forKey: "theme") == nil)
    #expect(defaults.data(forKey: "preferences.theme") == payload)

    defaults.set("wrong-type", forKey: "preferences.theme")
    await #expect(throws: ByteStoreError.invalidStoredData) {
        try await store.data(for: key)
    }
    try await store.removeData(for: key)
    #expect(try await store.data(for: key) == nil)
}
