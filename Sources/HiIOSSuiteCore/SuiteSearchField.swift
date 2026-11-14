import SwiftUI

#if os(iOS)
/// ``SuiteSearchField`` 的尺寸约定。
public enum SuiteSearchFieldMetrics {
    /// 搜索框高度：比系统搜索栏（约 36pt）高约 1/3，便于点按。
    public static let height: CGFloat = 48
}

/// 常驻显示的胶囊搜索框：放大镜、输入框，有输入时显示清除按钮。
///
/// 放在页面画布上，自身使用内容表面色，与画布有色差。不依赖系统 `.searchable`，首次进入即显示，
/// 也不会随列表滚动收起。提示与清除按钮的文案由使用方提供并负责本地化。
public struct SuiteSearchField: View {
    @Binding private var text: String
    private let prompt: String
    private let clearAccessibilityLabel: String
    private let onSubmit: @MainActor () -> Void

    public init(
        text: Binding<String>,
        prompt: String,
        clearAccessibilityLabel: String,
        onSubmit: @escaping @MainActor () -> Void = {}
    ) {
        self._text = text
        self.prompt = prompt
        self.clearAccessibilityLabel = clearAccessibilityLabel
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            TextField(prompt, text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit { onSubmit() }
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 32, height: SuiteSearchFieldMetrics.height)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(clearAccessibilityLabel)
            }
        }
        .font(.body)
        .padding(.leading, 16)
        .padding(.trailing, text.isEmpty ? 16 : 6)
        .frame(height: SuiteSearchFieldMetrics.height)
        .background(Color.suiteContentSurface, in: Capsule())
    }
}
#endif
