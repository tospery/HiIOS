import Foundation
import HiIOSCore
import Testing
import UIKit

@Test
func rgbaHexRoundTripsAlphaWithoutSwappingChannels() throws {
    let color = try #require(HiIOSColor.uiColor(rgbaHex: "#12345680"))
    #expect(HiIOSColor.rgbaHex(of: color) == "#12345680")
    #expect(HiIOSColor.uiColor(rgbaHex: "#12345G") == nil)
    #expect(HiIOSColor.uiColor(rgbaHex: "#12345") == nil)
}

@Test
func resourceReaderRejectsPathLikeNamesAndReportsMissingResource() {
    let reader = HiIOSResourceReader(bundle: .main)
    #expect(throws: HiIOSResourceError.invalidName) {
        try reader.data(named: "../private", withExtension: "json")
    }
    #expect(throws: HiIOSResourceError.missing) {
        try reader.data(named: "hiios-resource-that-does-not-exist", withExtension: "json")
    }
}
