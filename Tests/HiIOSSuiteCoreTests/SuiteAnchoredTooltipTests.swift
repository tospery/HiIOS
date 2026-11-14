import CoreGraphics
import HiIOSSuiteCore
import Testing

@Test
func tooltipSitsAboveAnchorWhenThereIsRoom() {
    let anchor = CGRect(x: 100, y: 80, width: 10, height: 10)
    let placement = SuiteAnchoredTooltipLayout.placement(
        anchor: anchor, bubbleSize: CGSize(width: 160, height: 38), containerWidth: 360, spaceAbove: 200)
    #expect(placement.isAbove)
    #expect(placement.bubble.maxY == anchor.minY - SuiteAnchoredTooltipLayout.gap
        - SuiteAnchoredTooltipLayout.arrowSize.height)
    #expect(placement.bubble.midX == anchor.midX)
    #expect(placement.arrowX == anchor.midX)
}

@Test
func tooltipMovesBelowAnchorWhenSpaceAboveIsShort() {
    let anchor = CGRect(x: 100, y: 4, width: 10, height: 10)
    let placement = SuiteAnchoredTooltipLayout.placement(
        anchor: anchor, bubbleSize: CGSize(width: 160, height: 38), containerWidth: 360, spaceAbove: 20)
    #expect(!placement.isAbove)
    #expect(placement.bubble.minY == anchor.maxY + SuiteAnchoredTooltipLayout.gap
        + SuiteAnchoredTooltipLayout.arrowSize.height)
}

@Test
func tooltipStaysInsideContainerAndArrowAvoidsRoundedCorner() {
    let leading = SuiteAnchoredTooltipLayout.placement(
        anchor: CGRect(x: 0, y: 80, width: 10, height: 10), bubbleSize: CGSize(width: 160, height: 38),
        containerWidth: 360, spaceAbove: 200)
    #expect(leading.bubble.minX == SuiteAnchoredTooltipLayout.margin)
    #expect(leading.arrowX == leading.bubble.minX + SuiteAnchoredTooltipLayout.cornerRadius
        + SuiteAnchoredTooltipLayout.arrowSize.width / 2)

    let trailing = SuiteAnchoredTooltipLayout.placement(
        anchor: CGRect(x: 350, y: 80, width: 10, height: 10), bubbleSize: CGSize(width: 160, height: 38),
        containerWidth: 360, spaceAbove: 200)
    #expect(trailing.bubble.maxX == 360 - SuiteAnchoredTooltipLayout.margin)
    #expect(trailing.arrowX <= trailing.bubble.maxX - SuiteAnchoredTooltipLayout.cornerRadius)
}
