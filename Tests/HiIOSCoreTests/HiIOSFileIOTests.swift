import Foundation
import HiIOSCore
import Testing

private struct FileFixture: Codable, Equatable {
    let name: String
    let count: Int
}

@Test
func fileIOCreatesParentAndRoundTripsJSONAtomically() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("hiios-fileio-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let file = root.appendingPathComponent("nested/state.json", isDirectory: false)
    let fileIO = HiIOSFileIO()
    let original = FileFixture(name: "first", count: 1)
    let replacement = FileFixture(name: "second", count: 2)

    try fileIO.writeJSON(original, to: file, createParentDirectory: true)
    #expect(try fileIO.readJSON(FileFixture.self, from: file) == original)
    try fileIO.writeJSON(replacement, to: file)
    #expect(try fileIO.readJSON(FileFixture.self, from: file) == replacement)
}

@Test
func fileIOEnforcesReadLimitAndRejectsInvalidPaths() throws {
    let root = FileManager.default.temporaryDirectory
        .appendingPathComponent("hiios-fileio-\(UUID().uuidString)", isDirectory: true)
    defer { try? FileManager.default.removeItem(at: root) }
    let fileIO = HiIOSFileIO()
    let file = root.appendingPathComponent("sample.bin")
    try fileIO.writeDataAtomically(Data("12345".utf8), to: file, createParentDirectory: true)

    #expect(try fileIO.readData(at: file, maximumBytes: 5) == Data("12345".utf8))
    #expect(throws: HiIOSFileError.tooLarge) { try fileIO.readData(at: file, maximumBytes: 4) }
    #expect(throws: HiIOSFileError.invalidConfiguration) { try fileIO.readData(at: file, maximumBytes: -1) }
    #expect(throws: HiIOSFileError.notDirectory) { try fileIO.ensureDirectory(at: file) }
    #expect(throws: HiIOSFileError.missing) {
        try fileIO.readData(at: root.appendingPathComponent("missing.bin"))
    }
    let remote = try #require(URL(string: "https://example.invalid/sample.bin"))
    #expect(throws: HiIOSFileError.invalidURL) { try fileIO.readData(at: remote) }
}
