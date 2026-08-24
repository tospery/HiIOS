import Alamofire
import Foundation
import HiIOSLog
import HiIOSNetwork

/// Alamofire transport adapter；公共 interface 只使用 HiIOS 自有值类型。
@available(macOS 10.15, *)
public struct AlamofireTransport: Transport {
    private let session: Session
    private let logger: Logger?

    public init(
        configuration: URLSessionConfiguration = .default,
        logger: Logger? = nil
    ) {
        session = Session(configuration: configuration)
        self.logger = logger
    }

    public func send(_ request: HTTPRequest) async throws(NetworkError) -> HTTPResponse {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body
        for (name, value) in request.headers.dictionary {
            urlRequest.setValue(value, forHTTPHeaderField: name)
        }

        _ = logger?.log(
            .info,
            event: "network.request",
            message: request.summary.description
        )

        let result = await session
            .request(urlRequest)
            .serializingData(emptyResponseCodes: Set(100...599))
            .response

        switch result.result {
        case let .success(data):
            guard let urlResponse = result.response else {
                throw NetworkError.invalidResponse
            }
            let response = HTTPResponse(
                statusCode: urlResponse.statusCode,
                headers: HTTPHeaders(Self.headers(from: urlResponse)),
                body: data
            )
            _ = logger?.log(
                .info,
                event: "network.response",
                message: response.summary.description
            )
            return response
        case let .failure(error):
            let mappedError = Self.map(error)
            _ = logger?.log(
                .warning,
                event: "network.failure",
                message: "method=\(request.method.rawValue) result=\(mappedError.rawValue)"
            )
            throw mappedError
        }
    }

    private static func headers(from response: HTTPURLResponse) -> [String: String] {
        response.allHeaderFields.reduce(into: [:]) { headers, entry in
            guard let name = entry.key as? String else { return }
            headers[name] = String(describing: entry.value)
        }
    }

    private static func map(_ error: AFError) -> NetworkError {
        if Task.isCancelled || error.isExplicitlyCancelledError {
            return .cancelled
        }
        if error.isInvalidURLError || error.isCreateURLRequestError {
            return .invalidRequest
        }
        if case .urlRequestValidationFailed = error {
            return .invalidRequest
        }
        if let urlError = error.underlyingError as? URLError {
            return map(urlError)
        }
        if error.isResponseSerializationError {
            return .invalidResponse
        }
        return .transportFailure
    }

    private static func map(_ error: URLError) -> NetworkError {
        switch error.code {
        case .cancelled:
            .cancelled
        case .timedOut:
            .timedOut
        case .badURL, .unsupportedURL:
            .invalidRequest
        case .notConnectedToInternet,
             .networkConnectionLost,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed,
             .internationalRoamingOff,
             .callIsActive,
             .dataNotAllowed:
            .connectivityUnavailable
        case .badServerResponse,
             .cannotDecodeContentData,
             .cannotDecodeRawData,
             .cannotParseResponse:
            .invalidResponse
        default:
            .transportFailure
        }
    }
}
