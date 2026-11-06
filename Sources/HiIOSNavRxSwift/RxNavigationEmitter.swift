import HiIOSNavCore
import RxSwift

/// 每个 Scene 自行持有 emitter；释放订阅即停止接收后续导航动作。
@MainActor
public final class RxNavigationEmitter<Route: Hashable & Sendable> {
    private let subject = PublishSubject<NavigationAction<Route>>()

    public init() {}

    public var actions: Observable<NavigationAction<Route>> {
        subject.asObservable()
    }

    public func send(_ action: NavigationAction<Route>) {
        subject.onNext(action)
    }
}
