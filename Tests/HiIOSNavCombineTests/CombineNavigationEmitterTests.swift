import Combine
import HiIOSNavCombine
import HiIOSNavCore
import Testing

private enum TestRoute: Hashable, Sendable { case details }

@MainActor
@Test
func combineEmitterPublishesTypedAction() {
    let emitter = CombineNavigationEmitter<TestRoute>()
    var received: [NavigationAction<TestRoute>] = []
    let subscription = emitter.actions.sink { received.append($0) }

    emitter.send(.push(.details))

    #expect(received == [.push(.details)])
    subscription.cancel()
}
