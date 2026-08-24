import HiIOSCore
import HiIOSPersistence
import Testing

@Test
func keychainErrorsExposeStableCategories() {
    #expect(KeychainStoreError.temporarilyUnavailable.category == .temporarilyUnavailable)
    #expect(KeychainStoreError.permissionDenied.category == .permissionDenied)
    #expect(KeychainStoreError.invalidStoredData.category == .invalidStoredData)
    #expect(KeychainStoreError.invalidConfiguration.category == .invalidConfiguration)
    #expect(KeychainStoreError.unexpected.category == .unexpected)
}

@Test
func keychainItemKeepsCompositionRootConfiguration() throws {
    let item = try KeychainItem(
        service: "com.example.shared",
        account: "app-family-seed",
        accessGroup: "TEAMID.com.example.shared"
    )

    #expect(item.service == "com.example.shared")
    #expect(item.account == "app-family-seed")
    #expect(item.accessGroup == "TEAMID.com.example.shared")
}

@Test
func keychainItemRejectsBlankConfigurationValues() {
    #expect(throws: KeychainStoreError.invalidConfiguration) {
        try KeychainItem(service: " ", account: "seed", accessGroup: "group")
    }
    #expect(throws: KeychainStoreError.invalidConfiguration) {
        try KeychainItem(service: "service", account: "\n", accessGroup: "group")
    }
    #expect(throws: KeychainStoreError.invalidConfiguration) {
        try KeychainItem(service: "service", account: "seed", accessGroup: "\t")
    }
}
