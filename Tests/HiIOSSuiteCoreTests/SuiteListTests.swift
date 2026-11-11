#if canImport(UIKit)
import HiIOSSuiteCore
import SwiftUI
import Testing

@Test @MainActor
func suiteListSectionRendersEveryRowVariantInBothAppearancesAtAccessibilityTextSize() {
    for appearance in [ColorScheme.light, .dark] {
        let section = SuiteListSection(header: "Header", footer: "Footer") {
            SuiteListRow(title: "Plain")
            SuiteListRow(
                title: "Value",
                trailingText: "A very long trailing value that must shrink",
                showsChevron: true,
                action: {}
            )
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

@Test @MainActor
func fullWidthSuiteListRendersRowsAndButtonRowsInBothAppearances() {
    for appearance in [ColorScheme.light, .dark] {
        let page = VStack(spacing: 16) {
            SuiteListSection(header: "Header") {
                SuiteListRow(title: "Value", trailingText: "Detail", showsChevron: true, action: {})
                SuiteListRow(title: "Last", showsDivider: false)
            }
            SuiteListSection {
                SuiteListButtonRow(title: "Destructive", role: .destructive, action: {})
            }
            SuiteListSection {
                SuiteListButtonRow(title: "Disabled", action: {})
                    .disabled(true)
            }
        }
        .suiteListStyle(.fullWidth)
        let renderer = ImageRenderer(
            content: page
                .frame(width: 320)
                .dynamicTypeSize(.accessibility3)
                .preferredColorScheme(appearance)
        )
        #expect(renderer.uiImage != nil)
    }
}
#endif
