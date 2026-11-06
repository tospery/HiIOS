#if canImport(UIKit)
import HiIOSSuiteCore
import SwiftUI
import Testing

@Test @MainActor
func loadMoreFooterRendersInBothAppearancesAtAccessibilityTextSize() {
    for appearance in [ColorScheme.light, .dark] {
        for state in [LoadMoreState.loading, .finished, .failed] {
            let footer = LoadMoreFooter(
                state: state,
                loadingLabel: "Loading",
                finishedLabel: "No more items",
                errorLabel: "Could not load items",
                retryLabel: "Retry",
                onRetry: {}
            )
            let renderer = ImageRenderer(
                content: footer
                    .frame(width: 320)
                    .dynamicTypeSize(.accessibility3)
                    .preferredColorScheme(appearance)
            )
            #expect(renderer.uiImage != nil)
        }
    }
}
#endif
