import HiIOSBase
import HiIOSSuiteLogOSLog
import Testing

@Test
func osLogSinkAcceptsRedactedRecordFromClient() {
    let client = LogClient(
        sink: OSLogSink(subsystem: "com.example.HiIOS", category: "test"),
        policy: .release
    )
    #expect(client.log(.info, event: "suite.oslog", message: "status=ok") == .emitted)
}
