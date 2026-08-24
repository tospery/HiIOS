import Foundation

public enum HTTPMethod: String, CaseIterable, Sendable {
    case connect = "CONNECT"
    case delete = "DELETE"
    case get = "GET"
    case head = "HEAD"
    case options = "OPTIONS"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
    case trace = "TRACE"
}

public struct HTTPHeaders: Equatable, Sendable {
    private struct Field: Equatable, Sendable {
        let name: String
        let value: String
    }

    private let fields: [String: Field]

    public init(_ values: [String: String] = [:]) {
        fields = values.reduce(into: [:]) { result, entry in
            result[Self.normalized(entry.key)] = Field(
                name: entry.key,
                value: entry.value
            )
        }
    }

    public subscript(name: String) -> String? {
        fields[Self.normalized(name)]?.value
    }

    public var dictionary: [String: String] {
        fields.values.reduce(into: [:]) { result, field in
            result[field.name] = field.value
        }
    }

    public var count: Int { fields.count }

    private static func normalized(_ name: String) -> String {
        name.lowercased()
    }
}

public struct HTTPRequest: Equatable, Sendable {
    public let url: URL
    public let method: HTTPMethod
    public let headers: HTTPHeaders
    public let body: Data?

    public init(
        url: URL,
        method: HTTPMethod = .get,
        headers: HTTPHeaders = HTTPHeaders(),
        body: Data? = nil
    ) {
        self.url = url
        self.method = method
        self.headers = headers
        self.body = body
    }

    public var summary: HTTPRequestSummary {
        HTTPRequestSummary(
            method: method,
            scheme: url.scheme,
            host: url.host,
            port: url.port,
            headerCount: headers.count,
            bodyByteCount: body?.count ?? 0
        )
    }
}

public struct HTTPResponse: Equatable, Sendable {
    public let statusCode: Int
    public let headers: HTTPHeaders
    public let body: Data

    public init(
        statusCode: Int,
        headers: HTTPHeaders = HTTPHeaders(),
        body: Data = Data()
    ) {
        self.statusCode = statusCode
        self.headers = headers
        self.body = body
    }

    public var isSuccessful: Bool {
        (200..<300).contains(statusCode)
    }

    public var summary: HTTPResponseSummary {
        HTTPResponseSummary(
            statusCode: statusCode,
            headerCount: headers.count,
            bodyByteCount: body.count
        )
    }
}

public struct HTTPRequestSummary: CustomStringConvertible, Equatable, Sendable {
    public let method: HTTPMethod
    public let scheme: String?
    public let host: String?
    public let port: Int?
    public let headerCount: Int
    public let bodyByteCount: Int

    public var description: String {
        "method=\(method.rawValue) scheme=\(scheme ?? "<none>") "
            + "host=\(host ?? "<none>") port=\(port.map(String.init) ?? "default") "
            + "headers=\(headerCount) bodyBytes=\(bodyByteCount)"
    }
}

public struct HTTPResponseSummary: CustomStringConvertible, Equatable, Sendable {
    public let statusCode: Int
    public let headerCount: Int
    public let bodyByteCount: Int

    public var description: String {
        "status=\(statusCode) headers=\(headerCount) bodyBytes=\(bodyByteCount)"
    }
}

public enum NetworkError: String, Error, Equatable, Sendable {
    case cancelled
    case invalidRequest
    case connectivityUnavailable
    case timedOut
    case invalidResponse
    case transportFailure
}

/// 通用 HTTP 传输 seam；具体 SDK 类型和错误只存在于 adapter 内。
public protocol Transport: Sendable {
    // SwiftLint 0.55 会把返回值前的 typed throws 类型误判为变量名。
    // swiftlint:disable:next identifier_name
    func send(_ request: HTTPRequest) async throws(NetworkError) -> HTTPResponse
}
