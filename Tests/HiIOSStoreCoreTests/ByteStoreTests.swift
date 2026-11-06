import HiIOSStoreCore
import Testing

@Test
func byteStoreKeysRejectBlankAndNullValues() throws {
    #expect(throws: ByteStoreError.invalidConfiguration) { try StoreKey(" \n") }
    #expect(throws: ByteStoreError.invalidConfiguration) { try StoreKey("a\0b") }
    #expect(try StoreKey("preferences.theme").rawValue == "preferences.theme")
}

@Test
func byteStoreErrorsExposeStableCategories() {
    #expect(ByteStoreError.invalidStoredData.category == .invalidStoredData)
    #expect(ByteStoreError.permissionDenied.category == .permissionDenied)
}
