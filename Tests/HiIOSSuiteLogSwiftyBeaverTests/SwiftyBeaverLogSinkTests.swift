import HiIOSBase
import HiIOSSuiteLogSwiftyBeaver
import SwiftyBeaver
import Testing

private final class RecordingDestination: BaseDestination {
    private(set) var messages: [String] = []

    override func send(
        _ level: SwiftyBeaver.Level,
        msg: String,
        thread: String,
        file: String,
        function: String,
        line: Int,
        context: Any? = nil
    ) -> String? {
        messages.append(msg)
        return msg
    }
}

@Test
func swiftyBeaverSinkWritesOnlyToExplicitDestinationAfterRedaction() {
    let initialGlobalDestinationCount = SwiftyBeaver.countDestinations()
    let destination = RecordingDestination()
    let client = LogClient(sink: SwiftyBeaverLogSink(destination: destination))

    client.log(
        .info,
        event: "auth.finished",
        message: "Authorization: Bearer private-token",
        metadata: ["access_token": "private-token", "result": "success"]
    )

    #expect(destination.messages.count == 1)
    #expect(!destination.messages[0].contains("private-token"))
    #expect(destination.messages[0].contains("result=success"))
    #expect(SwiftyBeaver.countDestinations() == initialGlobalDestinationCount)
}

@Test
func swiftyBeaverSinkHonorsExplicitMinimumLevel() {
    let destination = RecordingDestination()
    let client = LogClient(
        sink: SwiftyBeaverLogSink(destination: destination, minimumLevel: .warning),
        policy: .diagnostic
    )

    client.log(.info, event: "filtered")
    client.log(.warning, event: "kept")

    #expect(destination.messages.count == 1)
    #expect(destination.messages[0].contains("event=kept"))
}

@Test
func swiftyBeaverSinkHonorsDestinationMinimumLevel() {
    let destination = RecordingDestination()
    destination.minLevel = .error
    let client = LogClient(sink: SwiftyBeaverLogSink(destination: destination))

    client.log(.warning, event: "filtered")
    client.log(.error, event: "kept")

    #expect(destination.messages.count == 1)
    #expect(destination.messages[0].contains("event=kept"))
}
