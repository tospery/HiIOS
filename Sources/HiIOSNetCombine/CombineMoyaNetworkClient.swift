import Combine
#if canImport(CombineMoya)
import CombineMoya
#endif
import HiIOSNetCore
import Moya

/// 仅在选择 Combine 产品时引入 CombineMoya；订阅取消会取消底层请求。
public final class CombineMoyaNetworkClient {
    private let provider: MoyaProvider<MoyaRequestTarget>

    public init() {
        provider = MoyaHTTPBridge.provider()
    }

    public init(provider: MoyaProvider<MoyaRequestTarget>) {
        self.provider = provider
    }

    public func send(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, NetworkError> {
        guard MoyaHTTPBridge.isValid(request) else {
            return Fail(error: .invalidRequest).eraseToAnyPublisher()
        }
        return provider.requestPublisher(MoyaRequestTarget(request))
            .map(MoyaHTTPBridge.response)
            .mapError { MoyaHTTPBridge.error($0) }
            .eraseToAnyPublisher()
    }
}
