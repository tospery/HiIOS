import Foundation
import HiIOSNetCore
import Testing

@Test
func moyaBridgeRejectsNonHTTPAndCredentialedURLs() throws {
    let fileURL = try #require(URL(string: "file:///tmp/private"))
    let credentialedURL = try #require(URL(string: "https://user:secret@example.com/path"))
    let fragmentURL = try #require(URL(string: "https://example.com/path#secret"))
    let validURL = try #require(URL(string: "https://example.com/path?q=value"))

    #expect(!MoyaHTTPBridge.isValid(HTTPRequest(url: fileURL)))
    #expect(!MoyaHTTPBridge.isValid(HTTPRequest(url: credentialedURL)))
    #expect(!MoyaHTTPBridge.isValid(HTTPRequest(url: fragmentURL)))
    #expect(MoyaHTTPBridge.isValid(HTTPRequest(url: validURL)))
}

@Test
func moyaTransportRejectsInvalidURLBeforeSending() async throws {
    let url = try #require(URL(string: "file:///tmp/private"))
    let transport: any Transport = MoyaTransport()

    await #expect(throws: NetworkError.invalidRequest) {
        try await transport.send(HTTPRequest(url: url))
    }
}

@Test
func moyaTransportCancelsAnInFlightRequest() async throws {
    let url = try #require(URL(string: "https://example.invalid/path"))
    let provider = MoyaHTTPBridge.provider(stubClosure: { _ in .delayed(seconds: 2) })
    let transport = MoyaTransport(provider: provider)
    let request = HTTPRequest(url: url)

    let operation = Task { try await transport.send(request) }
    try await Task.sleep(for: .milliseconds(30))
    operation.cancel()

    await #expect(throws: NetworkError.cancelled) {
        try await operation.value
    }
}
