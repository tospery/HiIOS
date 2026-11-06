import HiIOSNetCore
import Moya
#if canImport(RxMoya)
import RxMoya
#endif
import RxSwift

/// 仅在选择 RxSwift 产品时引入 RxMoya；订阅释放会取消底层请求。
public final class RxMoyaNetworkClient {
    private let provider: MoyaProvider<MoyaRequestTarget>

    public init() {
        provider = MoyaHTTPBridge.provider()
    }

    public init(provider: MoyaProvider<MoyaRequestTarget>) {
        self.provider = provider
    }

    public func send(_ request: HTTPRequest) -> Single<HTTPResponse> {
        guard MoyaHTTPBridge.isValid(request) else {
            return .error(NetworkError.invalidRequest)
        }
        return provider.rx.request(MoyaRequestTarget(request))
            .map(MoyaHTTPBridge.response)
            .catch { .error(MoyaHTTPBridge.error($0)) }
    }
}
