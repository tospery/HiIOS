import HiIOSCore
import Testing

@Test
func failureCategoriesExposeStableNames() {
    #expect(FailureCategory.temporarilyUnavailable.rawValue == "temporarilyUnavailable")
    #expect(FailureCategory.permissionDenied.rawValue == "permissionDenied")
    #expect(FailureCategory.invalidStoredData.rawValue == "invalidStoredData")
    #expect(FailureCategory.invalidConfiguration.rawValue == "invalidConfiguration")
    #expect(FailureCategory.unexpected.rawValue == "unexpected")
}
