#if canImport(UIKit)
import HiIOSSuiteCore
import SwiftUI
import Testing

@Test
func pagingStaysOnPageWhenDragIsBelowThreshold() {
    let offset = SuitePagingScrollTargetBehavior.pageOffset(
        start: 0, proposed: 50, pageWidth: 400, contentWidth: 800, swipeThreshold: 0.2)
    #expect(offset == 0)
}

@Test
func pagingMovesOnePageOnceDragReachesThreshold() {
    #expect(SuitePagingScrollTargetBehavior.pageOffset(
        start: 0, proposed: 80, pageWidth: 400, contentWidth: 800, swipeThreshold: 0.2) == 400)
    #expect(SuitePagingScrollTargetBehavior.pageOffset(
        start: 400, proposed: 320, pageWidth: 400, contentWidth: 800, swipeThreshold: 0.2) == 0)
}

@Test
func pagingMovesAtMostOnePageForAFastFling() {
    let offset = SuitePagingScrollTargetBehavior.pageOffset(
        start: 0, proposed: 1_150, pageWidth: 400, contentWidth: 1_600, swipeThreshold: 0.2)
    #expect(offset == 400)
}

@Test
func pagingClampsAtBothEnds() {
    #expect(SuitePagingScrollTargetBehavior.pageOffset(
        start: 0, proposed: -200, pageWidth: 400, contentWidth: 800, swipeThreshold: 0.2) == 0)
    #expect(SuitePagingScrollTargetBehavior.pageOffset(
        start: 400, proposed: 700, pageWidth: 400, contentWidth: 800, swipeThreshold: 0.2) == 400)
}

@Test
func pagingSnapsAnUnalignedStartToTheNearestPage() {
    let offset = SuitePagingScrollTargetBehavior.pageOffset(
        start: 390, proposed: 395, pageWidth: 400, contentWidth: 1_200, swipeThreshold: 0.2)
    #expect(offset == 400)
}

@Test
func selectionOptionMatchesTitleOrKeywordsIgnoringCaseAndWhitespace() {
    let option = SuiteSelectionOption(id: "zh", title: "Chinese", keywords: ["zh"])
    #expect(option.matches(""))
    #expect(option.matches("  chin "))
    #expect(option.matches("ZH"))
    #expect(!option.matches("swift"))
}

@Test @MainActor
func selectionComponentsRenderInBothAppearancesAtAccessibilityTextSize() {
    for appearance in [ColorScheme.light, .dark] {
        let page = VStack(spacing: 16) {
            SuiteSearchField(text: .constant("swift"), prompt: "Search", clearAccessibilityLabel: "Clear")
            SuiteListSection {
                SuiteListSegmentedRow(
                    title: "Type",
                    options: [.init(value: 0, title: "Repository"), .init(value: 1, title: "User")],
                    selection: .constant(0))
                SuiteSelectableListRow(title: "Selected", isSelected: true, action: {})
                SuiteSelectableListRow(title: "Other", isSelected: false, showsDivider: false, action: {}) {
                    Circle().frame(width: 12, height: 12)
                }
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
