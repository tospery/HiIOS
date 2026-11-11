#if canImport(UIKit)
import HiIOSSuiteCore
import SwiftUI
import Testing

@Test @MainActor
func suiteListSectionRendersEveryRowVariantInBothAppearancesAtAccessibilityTextSize() {
    for appearance in [ColorScheme.light, .dark] {
        let section = SuiteListSection(header: "Header", footer: "Footer") {
            SuiteListRow(title: "Plain")
            SuiteListRow(title: "Value", trailingText: "A very long trailing value that must shrink", showsChevron: true,
                         action: {})
            SuiteListRow(title: "Dimmed", isDimmed: true) {
                Image(systemName: "envelope")
            }
            SuiteListRow(title: "Custom trailing", supportingText: "Supporting text", showsDivider: false) {
                Image(systemName: "gear")
            } trailing: {
                Toggle("", isOn: .constant(true)).labelsHidden()
            }
        }
        let renderer = ImageRenderer(
            content: section
                .frame(width: 320)
                .dynamicTypeSize(.accessibility3)
                .preferredColorScheme(appearance)
        )
        #expect(renderer.uiImage != nil)
    }
}
#endif
