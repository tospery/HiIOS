import SwiftUI

public struct NavigationPresentationBindings<Payload: Hashable & Sendable> {
    public let toast: Binding<ToastState?>
    public let alert: Binding<AlertState?>
    public let dialog: Binding<DialogState?>
    public let popup: Binding<PopupState<Payload>?>

    public init(
        toast: Binding<ToastState?>,
        alert: Binding<AlertState?>,
        dialog: Binding<DialogState?>,
        popup: Binding<PopupState<Payload>?>
    ) {
        self.toast = toast
        self.alert = alert
        self.dialog = dialog
        self.popup = popup
    }
}

/// 将通用呈现状态接到 Scene 根视图；文案、动作和弹层内容由项目注入。
public struct NavigationPresentationModifier<Payload: Hashable & Sendable, PopupContent: View>: ViewModifier {
    @Binding private var toast: ToastState?
    @Binding private var alert: AlertState?
    @Binding private var dialog: DialogState?
    @Binding private var popup: PopupState<Payload>?
    private let onAction: (PresentationAction) -> Void
    private let popupContent: (Payload) -> PopupContent

    public init(
        bindings: NavigationPresentationBindings<Payload>,
        onAction: @escaping (PresentationAction) -> Void,
        @ViewBuilder popupContent: @escaping (Payload) -> PopupContent
    ) {
        _toast = bindings.toast
        _alert = bindings.alert
        _dialog = bindings.dialog
        _popup = bindings.popup
        self.onAction = onAction
        self.popupContent = popupContent
    }

    public func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) { toastOverlay }
            .overlay { popupOverlay }
            .alert(alert?.title ?? "", isPresented: alertIsPresented) {
                if let alert {
                    ForEach(alert.actions) { action in
                        Button(action.title, role: action.role.buttonRole) {
                            self.alert = nil
                            onAction(action)
                        }
                    }
                }
            } message: {
                if let message = alert?.message { Text(message) }
            }
            .confirmationDialog(dialog?.title ?? "", isPresented: dialogIsPresented,
                                titleVisibility: .visible) {
                if let dialog {
                    ForEach(dialog.actions) { action in
                        Button(action.title, role: action.role.buttonRole) {
                            self.dialog = nil
                            onAction(action)
                        }
                    }
                }
            } message: {
                if let message = dialog?.message { Text(message) }
            }
            .task(id: toast?.id) {
                guard let current = toast, let duration = current.duration else { return }
                try? await Task.sleep(for: duration)
                guard !Task.isCancelled, toast?.id == current.id else { return }
                toast = nil
            }
    }

    private var alertIsPresented: Binding<Bool> {
        Binding(get: { alert != nil }, set: { if !$0 { alert = nil } })
    }

    private var dialogIsPresented: Binding<Bool> {
        Binding(get: { dialog != nil }, set: { if !$0 { dialog = nil } })
    }

    @ViewBuilder
    private var toastOverlay: some View {
        if let toast {
            Label(toast.message, systemImage: toast.style.symbolName)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.regularMaterial, in: Capsule())
                .padding(.top, 8)
                .onTapGesture { self.toast = nil }
                .accessibilityElement(children: .combine)
        }
    }

    @ViewBuilder
    private var popupOverlay: some View {
        if let popup {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture { self.popup = nil }
                popupContent(popup.payload)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    .padding()
            }
        }
    }
}

public extension View {
    func hiIOSNavigationPresentations<Payload: Hashable & Sendable, PopupContent: View>(
        bindings: NavigationPresentationBindings<Payload>,
        onAction: @escaping (PresentationAction) -> Void,
        @ViewBuilder popupContent: @escaping (Payload) -> PopupContent
    ) -> some View {
        modifier(NavigationPresentationModifier(
            bindings: bindings, onAction: onAction, popupContent: popupContent
        ))
    }
}

private extension ToastStyle {
    var symbolName: String {
        switch self {
        case .information: "info.circle"
        case .success: "checkmark.circle"
        case .warning: "exclamationmark.triangle"
        case .error: "xmark.octagon"
        }
    }
}

private extension PresentationActionRole {
    var buttonRole: ButtonRole? {
        switch self {
        case .default: nil
        case .cancel: .cancel
        case .destructive: .destructive
        }
    }
}
