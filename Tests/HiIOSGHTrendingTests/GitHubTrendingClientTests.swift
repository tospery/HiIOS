import Foundation
import HiIOSGHTrending
import HiIOSNetCore
import Testing

private let clientFixture = """
    <html><main><article class="Box-row">
      <h2><a href="/example-lab/toolkit">toolkit</a></h2>
    </article></main></html>
    """

private let clientDeveloperFixture = """
    <html><main><article class="Box-row">
      <h1><a href="/sampledev">Sample Developer</a></h1>
    </article></main></html>
    """

@Test
func clientCachesResponsesAndRevalidatesWithETag() async throws {
    let origin = try #require(URL(string: "https://github.com/trending"))
    let transport = ScriptedTrendingTransport(responses: [
        .success(htmlResponse(clientFixture, finalURL: origin, etag: "W/\"fixture-1\"")),
        .success(HTTPResponse(statusCode: 304, finalURL: origin))
    ])
    let client = GitHubTrendingClient(transport: transport, cacheLifetime: 0)
    let query = GitHubTrendingRepositoryQuery(programmingLanguage: "C++")

    let first = try await client.repositories(query)
    let second = try await client.repositories(query)
    let requests = await transport.requests()

    #expect(first == second)
    #expect(requests.count == 2)
    #expect(requests[0].url.host == "github.com")
    #expect(requests[0].url.absoluteString.contains("C++") == false)
    #expect(requests[1].headers["If-None-Match"] == "W/\"fixture-1\"")
}

@Test
func developerRequestUsesDedicatedPathAndSponsorableQuery() async throws {
    let origin = try #require(URL(string: "https://github.com/trending/developers"))
    let transport = ScriptedTrendingTransport(responses: [
        .success(htmlResponse(clientDeveloperFixture, finalURL: origin))
    ])
    let client = GitHubTrendingClient(transport: transport)
    let developers = try await client.developers(
        GitHubTrendingDeveloperQuery(programmingLanguage: "Swift", sponsorableOnly: true)
    )
    let requests = await transport.requests()

    #expect(developers.map(\.login) == ["sampledev"])
    #expect(requests.count == 1)
    #expect(requests[0].url.path == "/trending/developers/Swift")
    #expect(requests[0].url.query?.contains("sponsorable=true") == true)
}

@Test
func clientCoalescesConcurrentRequestsForSameQuery() async throws {
    let origin = try #require(URL(string: "https://github.com/trending"))
    let transport = ScriptedTrendingTransport(
        responses: [.success(htmlResponse(clientFixture, finalURL: origin))],
        delayMilliseconds: 100
    )
    let client = GitHubTrendingClient(transport: transport, cacheLifetime: 0)
    let query = GitHubTrendingRepositoryQuery()

    async let first = client.repositories(query)
    async let second = client.repositories(query)
    let pair = try await (first, second)

    #expect(pair.0 == pair.1)
    #expect(await transport.requests().count == 1)
}

@Test
func clientRejectsUnknownOrRedirectedOrigin() async throws {
    let origin = try #require(URL(string: "https://github.com/trending"))
    let foreign = try #require(URL(string: "https://example.invalid/trending"))
    let transport = ScriptedTrendingTransport(responses: [
        .success(htmlResponse(clientFixture, finalURL: nil)),
        .success(htmlResponse(clientFixture, finalURL: foreign)),
        .success(htmlResponse(clientFixture, finalURL: origin))
    ])
    let client = GitHubTrendingClient(transport: transport, cacheLifetime: 0)
    let query = GitHubTrendingRepositoryQuery()

    await #expect(throws: GitHubTrendingError.invalidOrigin) { try await client.repositories(query) }
    await #expect(throws: GitHubTrendingError.invalidOrigin) { try await client.repositories(query) }
    #expect(try await client.repositories(query).count == 1)
}

@Test
func clientClassifiesHttpContentTypeLimitAndCancellation() async throws {
    let origin = try #require(URL(string: "https://github.com/trending"))
    let transport = ScriptedTrendingTransport(responses: [
        .success(HTTPResponse(statusCode: 404, finalURL: origin)),
        .success(HTTPResponse(
            statusCode: 429,
            headers: HTTPHeaders(["Retry-After": "60"]),
            finalURL: origin
        )),
        .success(HTTPResponse(
            statusCode: 200,
            headers: HTTPHeaders(["Content-Type": "application/json"]),
            body: Data("{}".utf8),
            finalURL: origin
        )),
        .success(htmlResponse(String(repeating: "x", count: 2_000_001), finalURL: origin)),
        .failure(.cancelled)
    ])
    let client = GitHubTrendingClient(transport: transport, cacheLifetime: 0)
    let query = GitHubTrendingRepositoryQuery()

    await #expect(throws: GitHubTrendingError.httpStatus(404)) { try await client.repositories(query) }
    await #expect(throws: GitHubTrendingError.rateLimited(retryAfter: "60")) {
        try await client.repositories(query)
    }
    await #expect(throws: GitHubTrendingError.unsupportedContentType) {
        try await client.repositories(query)
    }
    await #expect(throws: GitHubTrendingError.responseTooLarge) { try await client.repositories(query) }
    await #expect(throws: GitHubTrendingError.cancelled) { try await client.repositories(query) }
}

private func htmlResponse(_ html: String, finalURL: URL?, etag: String? = nil) -> HTTPResponse {
    var values = ["Content-Type": "text/html; charset=utf-8"]
    if let etag { values["ETag"] = etag }
    return HTTPResponse(
        statusCode: 200,
        headers: HTTPHeaders(values),
        body: Data(html.utf8),
        finalURL: finalURL
    )
}

private actor ScriptedTrendingTransport: Transport {
    private var results: [Result<HTTPResponse, NetworkError>]
    private var received: [HTTPRequest] = []
    private let delayMilliseconds: Int

    init(responses: [Result<HTTPResponse, NetworkError>], delayMilliseconds: Int = 0) {
        results = responses
        self.delayMilliseconds = delayMilliseconds
    }

    func send(_ request: HTTPRequest) async throws(NetworkError) -> HTTPResponse {
        received.append(request)
        guard !results.isEmpty else { throw .transportFailure }
        let result = results.removeFirst()
        if delayMilliseconds > 0 {
            do {
                try await Task.sleep(for: .milliseconds(delayMilliseconds))
            } catch {
                throw .cancelled
            }
        }
        return try result.get()
    }

    func requests() -> [HTTPRequest] { received }
}
