import Foundation
import HiIOSNavCore
import HiIOSNavRxSwift
import Testing

private enum TestRoute: Hashable, Sendable { case details }

@MainActor
@Test
func rxEmitterPublishesTypedAction() {
    let emitter = RxNavigationEmitter<TestRoute>()
    var received: [NavigationAction<TestRoute>] = []
    let disposable = emitter.actions.subscribe(onNext: { received.append($0) })

    emitter.send(.push(.details))

    #expect(received == [.push(.details)])
    disposable.dispose()
}

@MainActor
@Test
func rxURLNavigatorRejectsDisallowedURLBeforeNavigation() throws {
    let navigator = RxURLNavigator()
    let url = try #require(URL(string: "https://example.com/private"))

    #expect(throws: URLNavigationError.disallowedURL) {
        try navigator.open(url, allowedBy: [], queryIsAllowed: { _ in true })
    }
}

@MainActor
@Test
func rxURLNavigatorRequiresCallerQueryValidation() throws {
    let navigator = RxURLNavigator()
    let url = try #require(URL(string: "https://example.com/callback?code=secret"))
    let pattern = HiIOSNavCore.URLPattern(
        scheme: "https", host: "example.com", path: "/callback", port: nil, fragment: nil
    )

    #expect(throws: URLNavigationError.disallowedURL) {
        try navigator.open(url, allowedBy: [pattern], queryIsAllowed: { $0.query == nil })
    }
}
