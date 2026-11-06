import Foundation
import Moya

/// Moya 专用 target；通用请求契约始终使用 HiIOS 自有值类型。
public struct MoyaRequestTarget: TargetType {
    public let request: HTTPRequest

    public init(_ request: HTTPRequest) {
        self.request = request
    }

    public var baseURL: URL { request.url }
    public var path: String { "" }
    public var method: Moya.Method { Moya.Method(rawValue: request.method.rawValue) }
    public var sampleData: Data { Data() }
    public var task: Moya.Task {
        request.body.map(Moya.Task.requestData) ?? .requestPlain
    }
    public var headers: [String: String]? { request.headers.dictionary }
}

/// 两种响应式适配器与 async transport 共用同一条请求和错误映射路径。
public enum MoyaHTTPBridge {
    public static func isValid(_ request: HTTPRequest) -> Bool {
        guard let components = URLComponents(url: request.url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = components.host, !host.isEmpty,
              components.user == nil, components.password == nil,
              components.fragment == nil else {
            return false
        }
        return true
    }

    public static func provider(
        stubClosure: @escaping MoyaProvider<MoyaRequestTarget>.StubClosure = MoyaProvider.neverStub
    ) -> MoyaProvider<MoyaRequestTarget> {
        MoyaProvider(endpointClosure: { target in
            Endpoint(
                url: target.request.url.absoluteString,
                sampleResponseClosure: { .networkResponse(200, Data()) },
                method: target.method,
                task: target.task,
                httpHeaderFields: target.headers
            )
        }, stubClosure: stubClosure)
    }

    public static func response(_ response: Moya.Response) -> HTTPResponse {
        let headers = response.response?.allHeaderFields.reduce(into: [String: String]()) { result, entry in
            guard let name = entry.key as? String else { return }
            result[name] = String(describing: entry.value)
        } ?? [:]
        return HTTPResponse(
            statusCode: response.statusCode,
            headers: HTTPHeaders(headers),
            body: response.data,
            finalURL: response.response?.url
        )
    }

    public static func error(_ error: any Error) -> NetworkError {
        if let networkError = error as? NetworkError { return networkError }
        if error is CancellationError { return .cancelled }
        if let moyaError = error as? MoyaError {
            if case let .underlying(underlying, _) = moyaError {
                return self.error(underlying)
            }
            if case .requestMapping = moyaError { return .invalidRequest }
            return .transportFailure
        }
        if let urlError = error as? URLError { return map(urlError) }
        return .transportFailure
    }

    private static func map(_ error: URLError) -> NetworkError {
        switch error.code {
        case .cancelled: return .cancelled
        case .timedOut: return .timedOut
        case .badURL, .unsupportedURL: return .invalidRequest
        case .notConnectedToInternet, .networkConnectionLost, .cannotFindHost,
             .cannotConnectToHost, .dnsLookupFailed, .internationalRoamingOff,
             .callIsActive, .dataNotAllowed: return .connectivityUnavailable
        case .badServerResponse, .cannotDecodeContentData,
             .cannotDecodeRawData, .cannotParseResponse: return .invalidResponse
        default: return .transportFailure
        }
    }
}
