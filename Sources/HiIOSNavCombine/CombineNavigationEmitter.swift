import Combine
import HiIOSNavCore

/// 每个 Scene 自行持有 emitter；取消订阅即停止接收后续导航动作。
@MainActor
public final class CombineNavigationEmitter<Route: Hashable & Sendable> {
    private let subject = PassthroughSubject<NavigationAction<Route>, Never>()

    public init() {}

    public var actions: AnyPublisher<NavigationAction<Route>, Never> {
        subject.eraseToAnyPublisher()
    }

    public func send(_ action: NavigationAction<Route>) {
        subject.send(action)
    }
}
