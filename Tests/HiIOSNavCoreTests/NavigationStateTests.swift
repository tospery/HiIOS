import Foundation
import HiIOSNavCore
import Testing

private enum TestRoute: String, Hashable, Sendable {
    case home
    case details
}

@Test
func navigationActionCarriesOnlyTypedDestination() {
    let action: NavigationAction<TestRoute> = .push(.details)
    #expect(action == .push(.details))
    #expect(action != .present(.details))
}

@Test
func presentationStatesUseCallerProvidedTextAndTypedPayload() {
    let action = PresentationAction(id: "delete", title: "Delete", role: .destructive)
    let alert = AlertState(title: "Confirm", message: "Proceed?", actions: [action])
    let dialog = DialogState(title: "Choose", actions: [action])
    let toast = ToastState(message: "Saved", style: .success)
    let popup = PopupState(payload: TestRoute.details)

    #expect(alert.actions.first?.id == "delete")
    #expect(dialog.actions.first?.role == .destructive)
    #expect(toast.message == "Saved")
    #expect(popup.payload == .details)
}
