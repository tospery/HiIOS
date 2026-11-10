import Foundation
import HiIOSBase
import Testing

private final class RecordingLogSink: LogSink, @unchecked Sendable {
    // 同步 sink 的测试替身用锁保护唯一的可变记录数组。
    private let lock = NSLock()
    private var stored: [LogOutputRecord] = []

    func write(_ record: LogOutputRecord) {
        lock.lock()
        stored.append(record)
        lock.unlock()
    }

    var records: [LogOutputRecord] {
        lock.lock()
        defer { lock.unlock() }
        return stored
    }
}

private actor RecordingAnalyticsSink: AnalyticsSink {
    private(set) var events: [AnalyticsEvent] = []

    func track(_ event: AnalyticsEvent) {
        events.append(event)
    }
}

@Test
func failureCategoriesKeepStableNames() {
    #expect(FailureCategory.invalidStoredData.rawValue == "invalidStoredData")
    #expect(FailureCategory.permissionDenied.rawValue == "permissionDenied")
}

@Test
func releaseLoggerFiltersDebugBeforeWriting() {
    let sink = RecordingLogSink()
    let client = LogClient(sink: sink)

    #expect(client.log(.debug, event: "debug", message: "access_token=secret") == .filtered)
    #expect(sink.records.isEmpty)
}

@Test
func diagnosticLoggerRedactsBeforeWriting() throws {
    let sink = RecordingLogSink()
    let client = LogClient(sink: sink, policy: .diagnostic)
    let secret = "github-secret"

    #expect(client.log(
        .debug,
        event: "auth.callback",
        message: "Authorization: Bearer \(secret) callback=https://example.com/auth?code=oauth-secret",
        metadata: ["access_token": secret, "result": "success"]
    ) == .emitted)

    let record = try #require(sink.records.first)
    #expect(record.level == .debug)
    #expect(record.metadata["access_token"] == "<redacted>")
    #expect(record.metadata["result"] == "success")
    #expect(!record.message.contains(secret))
    #expect(!record.message.contains("oauth-secret"))
}

@Test
func bothLogPoliciesRedactSecretsInEventAndMetadata() {
    let raw = LogRecord(
        level: .info,
        event: "session=private-session",
        metadata: [
            "requestBody": "{\"password\":\"private-password\"}",
            "url": "https://example.com/callback?state=private-state",
            "status": "ok"
        ]
    )

    for policy in [LogRedactionPolicy.release, .diagnostic] {
        let redacted = policy.redact(raw)
        #expect(!redacted.event.contains("private-session"))
        #expect(redacted.metadata["requestBody"] == "<redacted>")
        #expect(!redacted.metadata["url", default: ""].contains("private-state"))
        #expect(redacted.metadata["status"] == "ok")
    }
}

@Test
func unredactedPolicyPassesValuesThroughAndAllowsDebug() {
    let raw = LogRecord(
        level: .debug,
        event: "network.request",
        message: "Authorization: Bearer development-token",
        metadata: ["access_token": "development-token", "url": "https://example.com/?code=abc"]
    )

    #expect(LogRedactionPolicy.unredacted.allows(.verbose))
    let output = LogRedactionPolicy.unredacted.redact(raw)
    #expect(output.isRedacted == false)
    #expect(output.message == raw.message)
    #expect(output.metadata == raw.metadata)
    #expect(LogRedactionPolicy.release.redact(raw).isRedacted)
}

@Test
func eachRouteAppliesItsOwnPolicy() {
    let protected = RecordingLogSink()
    let console = RecordingLogSink()
    let client = LogClient(routes: [
        LogRoute(sink: protected, policy: .unredacted),
        LogRoute(sink: console, policy: .release)
    ])

    #expect(client.log(.debug, event: "debug.only", message: "token=secret") == .emitted)
    client.log(.info, event: "info", metadata: ["token": "secret"])

    #expect(protected.records.map(\.event) == ["debug.only", "info"])
    #expect(protected.records[1].metadata["token"] == "secret")
    #expect(console.records.map(\.event) == ["info"])
    #expect(console.records[0].metadata["token"] == "<redacted>")
    #expect(LogClient(routes: []).log(.error, event: "nowhere") == .filtered)
}

@Test
func analyticsContractPreservesTypedScalarValuesAcrossActorBoundary() async {
    let sink = RecordingAnalyticsSink()
    let event = AnalyticsEvent(
        name: "screen.opened",
        parameters: ["screen": .string("home"), "count": .integer(2), "success": .boolean(true)]
    )

    await sink.track(event)

    let events = await sink.events
    #expect(events == [event])
}

@Test
func sharingContractCarriesPlatformNeutralContent() {
    let request = ShareRequest(content: .text("Hello"), title: "Greeting")
    #expect(request.content == .text("Hello"))
    #expect(ShareResult.failed(.temporarilyUnavailable) != .cancelled)
}
