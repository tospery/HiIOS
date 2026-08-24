import Foundation
import HiIOSNetwork
import HiIOSNetworkAlamofire
import Testing

@Test
func alamofireTransportSendsAndReturnsOnlyHiIOSValues() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [TransportURLProtocol.self]
    let transport: any Transport = AlamofireTransport(configuration: configuration)
    let body = Data("request-body".utf8)
    let request = HTTPRequest(
        url: try #require(URL(string: "https://example.com/success?token=query-secret")),
        method: .post,
        headers: HTTPHeaders([
            "Authorization": "Bearer authorization-secret",
            "Cookie": "session=cookie-secret"
        ]),
        body: body
    )

    let response = try await transport.send(request)

    #expect(response.statusCode == 202)
    #expect(response.headers["X-Echo-Method"] == "POST")
    #expect(response.headers["X-Echo-Authorization"] == "Bearer authorization-secret")
    #expect(response.body == body)
}

@Test
func alamofireTransportMapsFoundationFailuresToStableErrors() async throws {
    let transport = makeTransport()

    await #expect(throws: NetworkError.connectivityUnavailable) {
        try await transport.send(request(path: "/offline"))
    }
    await #expect(throws: NetworkError.timedOut) {
        try await transport.send(request(path: "/timeout"))
    }
    await #expect(throws: NetworkError.invalidResponse) {
        try await transport.send(request(path: "/invalid-response"))
    }
    await #expect(throws: NetworkError.transportFailure) {
        try await transport.send(request(path: "/transport-failure"))
    }
    await #expect(throws: NetworkError.invalidRequest) {
        let getWithBody = HTTPRequest(
            url: try #require(URL(string: "https://example.com/invalid-request")),
            method: .get,
            body: Data("unexpected-body".utf8)
        )
        _ = try await transport.send(getWithBody)
    }
}

@Test
func cancellingTheCallingTaskCancelsTransportWithAStableError() async throws {
    let transport = makeTransport()
    let operation = Task {
        try await transport.send(request(path: "/cancel"))
    }

    await Task.yield()
    operation.cancel()

    await #expect(throws: NetworkError.cancelled) {
        try await operation.value
    }
}

private func makeTransport() -> AlamofireTransport {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [TransportURLProtocol.self]
    return AlamofireTransport(configuration: configuration)
}

private func request(path: String) throws -> HTTPRequest {
    let url = try #require(URL(string: "https://example.com\(path)"))
    return HTTPRequest(url: url)
}

private final class TransportURLProtocol: URLProtocol, @unchecked Sendable {
    override static func canInit(with request: URLRequest) -> Bool {
        request.url?.host == "example.com"
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        switch request.url?.path {
        case "/offline":
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        case "/timeout":
            client?.urlProtocol(self, didFailWithError: URLError(.timedOut))
            return
        case "/invalid-response":
            client?.urlProtocol(self, didFailWithError: URLError(.cannotParseResponse))
            return
        case "/transport-failure":
            client?.urlProtocol(self, didFailWithError: URLError(.secureConnectionFailed))
            return
        case "/cancel":
            return
        default:
            break
        }

        guard let url = request.url,
              let response = HTTPURLResponse(
                  url: url,
                  statusCode: 202,
                  httpVersion: "HTTP/1.1",
                  headerFields: [
                      "Content-Type": "application/octet-stream",
                      "X-Echo-Method": request.httpMethod ?? "",
                      "X-Echo-Authorization": request.value(forHTTPHeaderField: "Authorization") ?? ""
                  ]
              )
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: requestBody())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private func requestBody() -> Data {
        if let body = request.httpBody {
            return body
        }
        guard let stream = request.httpBodyStream else { return Data() }

        stream.open()
        defer { stream.close() }
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 1_024)
        while stream.hasBytesAvailable {
            let count = stream.read(&buffer, maxLength: buffer.count)
            guard count > 0 else { break }
            data.append(buffer, count: count)
        }
        return data
    }
}
