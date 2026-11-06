import Foundation
import Moya

/// 以 Moya 执行通用 HTTP 请求；Moya 类型不进入 Transport 契约。
public actor MoyaTransport: Transport {
    private let provider: MoyaProvider<MoyaRequestTarget>
    private var inFlight: [UUID: Cancellable] = [:]
    private var continuations: [UUID: CheckedContinuation<Result<HTTPResponse, NetworkError>, Never>] = [:]

    public init() {
        provider = MoyaHTTPBridge.provider()
    }

    public init(provider: MoyaProvider<MoyaRequestTarget>) {
        self.provider = provider
    }

    public func send(_ request: HTTPRequest) async throws(NetworkError) -> HTTPResponse {
        guard MoyaHTTPBridge.isValid(request) else { throw .invalidRequest }
        guard !_Concurrency.Task.isCancelled else { throw .cancelled }

        let identifier = UUID()
        let result: Result<HTTPResponse, NetworkError> = await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                continuations[identifier] = continuation
                let completion: @Sendable (Result<Moya.Response, MoyaError>) -> Void = { result in
                    let mapped = result
                        .map(MoyaHTTPBridge.response)
                        .mapError(MoyaHTTPBridge.error)
                    _Concurrency.Task { await self.complete(identifier, with: mapped) }
                }
                let cancellable = provider.request(MoyaRequestTarget(request), completion: completion)
                inFlight[identifier] = cancellable
                if _Concurrency.Task.isCancelled {
                    cancellable.cancel()
                    complete(identifier, with: .failure(.cancelled))
                }
            }
        } onCancel: {
            _Concurrency.Task { await self.cancel(identifier) }
        }

        guard !_Concurrency.Task.isCancelled else { throw .cancelled }
        return try result.get()
    }

    private func cancel(_ identifier: UUID) {
        inFlight[identifier]?.cancel()
        complete(identifier, with: .failure(.cancelled))
    }

    private func complete(
        _ identifier: UUID,
        with result: Result<HTTPResponse, NetworkError>
    ) {
        guard let continuation = continuations.removeValue(forKey: identifier) else { return }
        inFlight[identifier] = nil
        continuation.resume(returning: result)
    }
}
