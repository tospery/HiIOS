import Foundation
import HiIOSDevice
import HiIOSLog
import Testing

@Test
func releasePolicyRedactsSensitiveMetadata() {
    let record = LogRecord(
        event: "auth.completed",
        message: "authentication completed",
        metadata: [
            "access_token": "github-secret",
            "Authorization": "Bearer atlas-secret",
            "Cookie": "session=secret",
            "appFamilySeed": "11111111-2222-3333-4444-555555555555",
            "requestBody": "{\"code\":\"secret\"}",
            "result": "success"
        ]
    )

    let redacted = RedactionPolicy.release.redact(record)

    #expect(redacted.metadata["access_token"] == "<redacted>")
    #expect(redacted.metadata["Authorization"] == "<redacted>")
    #expect(redacted.metadata["Cookie"] == "<redacted>")
    #expect(redacted.metadata["appFamilySeed"] == "<redacted>")
    #expect(redacted.metadata["requestBody"] == "<redacted>")
    #expect(redacted.metadata["result"] == "success")
}

@Test
func diagnosticPolicyStillRedactsSecrets() {
    let record = LogRecord(
        event: "auth.callback",
        message: "access_token=diagnostic-secret",
        metadata: ["appFamilySeed": "11111111-2222-3333-4444-555555555555"]
    )

    let redacted = RedactionPolicy.diagnostic.redact(record)

    #expect(!redacted.message.contains("diagnostic-secret"))
    #expect(redacted.metadata["appFamilySeed"] == "<redacted>")
    #expect(RedactionPolicy.diagnostic.allows(.debug))
}

@Test
func releasePolicyRedactsSecretsFromMessageText() {
    let message = """
        Authorization: Bearer atlas-secret
        Cookie: session=secret
        callback=https://example.com/oauth/callback?code=oauth-secret&state=state-secret
        access_token=github-secret
        oauth_state=state-secret
        appFamilySeed=11111111-2222-3333-4444-555555555555
        requestBody={"credential":"provider-secret"}
        operation failed
        """

    let redacted = RedactionPolicy.release.redact(
        LogRecord(event: "auth.failed", message: message)
    )

    #expect(!redacted.message.contains("atlas-secret"))
    #expect(!redacted.message.contains("session=secret"))
    #expect(!redacted.message.contains("oauth-secret"))
    #expect(!redacted.message.contains("state-secret"))
    #expect(!redacted.message.contains("github-secret"))
    #expect(!redacted.message.contains("11111111-2222-3333-4444-555555555555"))
    #expect(!redacted.message.contains("provider-secret"))
    #expect(redacted.message.contains("https://example.com/oauth/callback?<redacted>"))
    #expect(redacted.message.contains("operation failed"))
}

@Test
func policiesRedactSessionAndCookieAssignmentsWithoutRemovingOrdinaryText() {
    let message = """
        session=lowercase-session-secret
        SESSION : "uppercase-session-secret"
        Cookie=cookie-secret
        cookie = 'lowercase-cookie-secret'
        sessionSummary=completed
        cookiePolicy=accepted
        """

    for policy in [RedactionPolicy.release, .diagnostic] {
        let redacted = policy.redact(
            LogRecord(event: "auth.summary", message: message)
        ).message

        #expect(!redacted.contains("lowercase-session-secret"))
        #expect(!redacted.contains("uppercase-session-secret"))
        #expect(!redacted.contains("cookie-secret"))
        #expect(!redacted.contains("lowercase-cookie-secret"))
        #expect(redacted.contains("sessionSummary=completed"))
        #expect(redacted.contains("cookiePolicy=accepted"))
    }
}

@Test
func callbackSecretsAreRedactedAcrossURLForms() {
    let message = """
        deepLink=atlashub://callback?code=custom-code&state=custom-state
        relative=/oauth/callback?code=relative-code&state=relative-state
        query=code=bare-code&state=bare-state
        """

    let redacted = RedactionPolicy.release.redact(
        LogRecord(event: "auth.callback", message: message)
    ).message

    #expect(!redacted.contains("custom-code"))
    #expect(!redacted.contains("custom-state"))
    #expect(!redacted.contains("relative-code"))
    #expect(!redacted.contains("relative-state"))
    #expect(!redacted.contains("bare-code"))
    #expect(!redacted.contains("bare-state"))
    #expect(redacted.contains("atlashub://callback?<redacted>"))
    #expect(redacted.contains("/oauth/callback?<redacted>"))
}

@Test
func appFamilySeedDescriptionsAndRawValueInterpolationAreRedacted() throws {
    let uuid = try #require(
        UUID(uuidString: "11111111-2222-4333-8444-555555555555")
    )
    let seed = AppFamilySeed(rawValue: uuid)
    let message = "seed=\(seed) rawValue=\(seed.rawValue)"

    #expect(String(describing: seed) == "<redacted>")
    #expect(String(reflecting: seed) == "<redacted>")
    for policy in [RedactionPolicy.release, .diagnostic] {
        let redacted = policy.redact(
            LogRecord(event: "device.identity", message: message)
        ).message
        #expect(!redacted.contains(uuid.uuidString))
    }
}

@Test
func releasePolicyFiltersVerboseAndDebugLevels() {
    #expect(!RedactionPolicy.release.allows(.verbose))
    #expect(!RedactionPolicy.release.allows(.debug))
    #expect(RedactionPolicy.release.allows(.info))
    #expect(RedactionPolicy.release.allows(.warning))
    #expect(RedactionPolicy.release.allows(.error))
}

@Test
func loggerReportsWhenReleasePolicyFiltersARecord() {
    let logger = Logger(
        subsystem: "com.example.app",
        category: "authentication",
        policy: .release
    )

    let disposition = logger.log(
        .debug,
        event: "auth.callback",
        message: "debug-only detail"
    )

    #expect(disposition == .filtered)
}
