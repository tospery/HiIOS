#if canImport(UIKit)
import HiIOSSuiteCore
import SwiftUI
import Testing

@Test @MainActor
func suiteTabBarRendersSelectedAndUnselectedItemsInBothAppearances() {
    let items = [
        SuiteTabBarItem(tag: 0, title: "Home", systemImage: "house", accessibilityIdentifier: "tab.home"),
        SuiteTabBarItem(tag: 1, title: "Search", systemImage: "magnifyingglass"),
        SuiteTabBarItem(tag: 2, title: "A very long tab title", systemImage: "person.crop.circle"),
    ]
    for appearance in [ColorScheme.light, .dark] {
        let renderer = ImageRenderer(
            content: SuiteTabBar(items: items, selection: 1) { _ in }
                .frame(width: 320)
                .preferredColorScheme(appearance)
        )
        #expect(renderer.uiImage != nil)
    }
    #expect(SuiteTabBar<Int>.height == 49)
}

@Test @MainActor
func suitePageLoadingViewRendersWithAndWithoutAccessibilityLabel() {
    for label in [nil, "Loading repository"] as [String?] {
        let renderer = ImageRenderer(
            content: SuitePageLoadingView(accessibilityLabel: label).frame(width: 200, height: 200)
        )
        #expect(renderer.uiImage != nil)
    }
}

@Test @MainActor
func suiteToolbarRendersPlainItemsInsideNavigationStack() {
    let renderer = ImageRenderer(
        content: NavigationStack {
            Text("Body")
                .suiteToolbar {
                    ToolbarItem(placement: .topBarTrailing) { Button("Done") {} }
                    ToolbarItem(placement: .topBarLeading) { Image(systemName: "chevron.backward") }
                }
        }
        .frame(width: 320, height: 200)
    )
    #expect(renderer.uiImage != nil)
}

@Test
func suiteListRowMinimumHeightMatchesSystemListRows() {
    #expect(SuiteListRowMetrics.minimumHeight == 52)
}
#endif
