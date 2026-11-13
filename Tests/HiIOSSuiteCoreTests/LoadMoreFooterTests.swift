#if canImport(UIKit)
import HiIOSSuiteCore
import SwiftUI
import Testing

private let labels = LoadMoreLabels(
    loading: "Loading", loadMore: "Load more", finished: "No more items", retry: "Retry")

@Test @MainActor
func loadMoreFooterRendersInBothAppearancesAtAccessibilityTextSize() {
    let states: [LoadMoreState] = [.loading, .more, .finished, .failed("Could not load items")]
    for appearance in [ColorScheme.light, .dark] {
        for state in states {
            let footer = LoadMoreFooter(
                state: state, labels: labels, accessibilityIdentifier: "list", onLoadMore: {})
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

@Test @MainActor
func loadMoreFooterRendersInsideListCanvasRows() {
    let list = List {
        Text("Row").suiteListRowSurface()
        LoadMoreFooter(state: .finished, labels: labels, onLoadMore: {})
    }
    .suiteListCanvas()
    .suiteNavigationTitle("Title")
    let renderer = ImageRenderer(content: NavigationStack { list }.frame(width: 320, height: 240))
    #expect(renderer.uiImage != nil)
    let blocks = ScrollView {
        VStack(spacing: 16) {
            Text("Body").suiteContentBlock()
            Text("Comment").suiteContentBlock(padding: 12)
        }
    }
    .suitePageCanvas()
    #expect(ImageRenderer(content: blocks.frame(width: 320, height: 240)).uiImage != nil)
}

@Test
func loadMoreStateDistinguishesFailureMessages() {
    #expect(LoadMoreState.failed("a") != .failed("b"))
    #expect(LoadMoreState.more != .finished)
}

@Test
func loadMoreStatePrefersLoadingThenFailureThenMore() {
    #expect(LoadMoreState(isLoading: true, failure: "x", hasMore: true) == .loading)
    #expect(LoadMoreState(isLoading: false, failure: "x", hasMore: true) == .failed("x"))
    #expect(LoadMoreState(isLoading: false, failure: nil, hasMore: true) == .more)
    #expect(LoadMoreState(isLoading: false, failure: nil, hasMore: false) == .finished)
}

@Test @MainActor
func contentSurfaceDiffersFromPageCanvas() {
    for style in [UIUserInterfaceStyle.light, .dark] {
        let traits = UITraitCollection(userInterfaceStyle: style)
        let canvas = UIColor(Color.suitePageCanvas).resolvedColor(with: traits)
        let surface = UIColor(Color.suiteContentSurface).resolvedColor(with: traits)
        #expect(canvas != surface)
    }
}
#endif
