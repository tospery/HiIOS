import Foundation
import HiIOSNetwork
import Testing

@Test
func httpContractsPreserveRequestAndResponseValues() async throws {
    let url = try #require(URL(string: "https://api.example.com/repos?page=2"))
    let body = Data("{\"name\":\"AtlasHub\"}".utf8)
    let request = HTTPRequest(
        url: url,
        method: .post,
        headers: HTTPHeaders([
            "Content-Type": "application/json",
            "X-Request-ID": "request-1"
        ]),
        body: body
    )

    #expect(request.url == url)
    #expect(request.method == .post)
    #expect(request.headers["content-type"] == "application/json")
    #expect(request.headers["X-REQUEST-ID"] == "request-1")
    #expect(request.body == body)

    let transport: any Transport = EchoTransport()
    let response = try await transport.send(request)

    #expect(response.statusCode == 202)
    #expect(response.headers["content-type"] == "application/json")
    #expect(response.body == body)
    #expect(response.isSuccessful)
}

@Test
func httpSummariesNeverExposeCredentialsQueryOrBody() throws {
    let request = HTTPRequest(
        url: try #require(
            URL(string: "https://api.example.com/private?access_token=query-secret#fragment-secret")
        ),
        method: .post,
        headers: HTTPHeaders([
            "Authorization": "Bearer authorization-secret",
            "Cookie": "session=cookie-secret"
        ]),
        body: Data("body-secret".utf8)
    )
    let response = HTTPResponse(
        statusCode: 401,
        headers: HTTPHeaders(["Set-Cookie": "response-cookie-secret"]),
        body: Data("response-body-secret".utf8)
    )

    let requestSummary = request.summary.description
    let responseSummary = response.summary.description

    for secret in [
        "query-secret",
        "fragment-secret",
        "authorization-secret",
        "cookie-secret",
        "body-secret",
        "response-cookie-secret",
        "response-body-secret"
    ] {
        #expect(!requestSummary.contains(secret))
        #expect(!responseSummary.contains(secret))
    }
    #expect(requestSummary.contains("method=POST"))
    #expect(requestSummary.contains("host=api.example.com"))
    #expect(responseSummary.contains("status=401"))
}

private struct EchoTransport: Transport {
    func send(_ request: HTTPRequest) async throws(NetworkError) -> HTTPResponse {
        HTTPResponse(
            statusCode: 202,
            headers: HTTPHeaders(["Content-Type": "application/json"]),
            body: request.body ?? Data()
        )
    }
}
