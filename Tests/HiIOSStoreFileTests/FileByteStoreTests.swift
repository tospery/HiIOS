import Foundation
import HiIOSStoreCore
import HiIOSStoreFile
import Testing

@Test
func fileStoreWritesAtomicallyWithoutExposingKeyInFilename() async throws {
    let directory = FileManager.default.temporaryDirectory
        .appendingPathComponent("hiios-store-tests-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let store = try FileByteStore(rootDirectory: directory)
    let key = try StoreKey("private.user.identifier")
    let payload = Data("payload".utf8)

    #expect(try await store.data(for: key) == nil)
    try await store.set(payload, for: key)
    #expect(try await store.data(for: key) == payload)
    let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
    #expect(files.count == 1)
    #expect(files.allSatisfy { !$0.contains("private.user.identifier") })

    try await store.removeData(for: key)
    #expect(try await store.data(for: key) == nil)
    try await store.removeData(for: key)
}
