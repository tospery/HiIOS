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

@Test @MainActor
func suiteTabBarAcceptsItemOffset() {
    let items = [SuiteTabBarItem(tag: 0, title: "Home", systemImage: "house")]
    let renderer = ImageRenderer(
        content: SuiteTabBar(items: items, selection: 0, itemOffset: 12) { _ in }.frame(width: 320)
    )
    #expect(renderer.uiImage != nil)
}

@Test @MainActor
func suiteToolbarItemStyleRendersEnabledAndDisabledButtons() {
    for disabled in [false, true] {
        let renderer = ImageRenderer(
            content: Button {} label: { Image(systemName: "square.and.arrow.up") }
                .suiteToolbarItemStyle()
                .disabled(disabled)
                .frame(width: 44, height: 44)
        )
        #expect(renderer.uiImage != nil)
    }
}

@Test
func suiteActivityIndicatorFadesSpokesBehindTheLeadingOne() {
    #expect(SuiteActivityIndicator.spokeOpacity(spoke: 3, head: 3) == 1)
    #expect(SuiteActivityIndicator.spokeOpacity(spoke: 2, head: 3) < 1)
    #expect(SuiteActivityIndicator.spokeOpacity(spoke: 4, head: 3) == 0.2)
}

@Test @MainActor
func suitePagerTabsRenderInBothAppearances() {
    let tabs = [
        SuitePagerTab(tag: 0, title: "Repositories"), SuitePagerTab(tag: 1, title: "Followers"),
        SuitePagerTab(tag: 2, title: "Following"), SuitePagerTab(tag: 3, title: "Stars"),
        SuitePagerTab(tag: 4, title: "Watching")
    ]
    for appearance in [ColorScheme.light, .dark] {
        let renderer = ImageRenderer(
            content: SuitePagerTabs(tabs: tabs, selection: .constant(1)) { Text("Page \($0)") }
                .frame(width: 320, height: 240)
                .preferredColorScheme(appearance)
        )
        #expect(renderer.uiImage != nil)
    }
    #expect(SuitePagerTabs<Int, Text>.tabHeight == 48)
}

@Test @MainActor
func suiteAnchoredTooltipRendersOverItsContent() {
    let renderer = ImageRenderer(
        content: Color.clear
            .frame(width: 320, height: 120)
            .suiteAnchoredTooltip(
                text: "2026-08-03: 9", anchor: CGRect(x: 100, y: 60, width: 10, height: 10), reservedTop: 0) {}
    )
    #expect(renderer.uiImage != nil)
}

@Test
func suiteListRowMinimumHeightMatchesSystemListRows() {
    #expect(SuiteListRowMetrics.minimumHeight == 52)
}
#endif
