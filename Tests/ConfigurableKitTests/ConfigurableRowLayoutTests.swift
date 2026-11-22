@testable import ConfigurableKit
import Foundation
import Testing

struct ConfigurableRowLayoutTests {
    @Test func shortValueStaysBesideTitleWithExplanation() {
        #expect(!ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 120, titleWidth: 90, isDescriptionVisible: true, spacing: 10
        ))
    }

    @Test func valueWiderThanHalfTheRowMovesBelowWithExplanation() {
        // 340 / 2 - 10 = 160 points are left beside an explanation.
        #expect(ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 161, titleWidth: 90, isDescriptionVisible: true, spacing: 10
        ))
        #expect(!ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 160, titleWidth: 90, isDescriptionVisible: true, spacing: 10
        ))
    }

    @Test func withoutExplanationValueMayUseWhatTheTitleLeaves() {
        // 340 - 10 - 90 = 240 points are left beside a 90 point title.
        #expect(!ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 240, titleWidth: 90, isDescriptionVisible: false, spacing: 10
        ))
        #expect(ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 241, titleWidth: 90, isDescriptionVisible: false, spacing: 10
        ))
    }

    @Test func longTitleNeverPushesSmallControlsBelow() {
        // A switch beside a title that would need the whole row stays beside it.
        #expect(!ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 51, titleWidth: 600, isDescriptionVisible: false, spacing: 10
        ))
    }

    @Test func unknownSizesKeepTrailingLayout() {
        #expect(!ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 0, valueWidth: 200, titleWidth: 90, isDescriptionVisible: true, spacing: 10
        ))
        #expect(!ConfigurableRowLayout.prefersValueBelowTitle(
            rowWidth: 340, valueWidth: 0, titleWidth: 90, isDescriptionVisible: true, spacing: 10
        ))
    }

    @Test func textValueWrapsBesideTitleBeforeMovingBelow() {
        // 160 points are left beside an explanation in a 340 point row.
        func arrangement(lines: Int, width: CGFloat = 300) -> ConfigurableValueArrangement {
            ConfigurableRowLayout.valueArrangement(
                rowWidth: 340, valueWidth: width, titleWidth: 90, isDescriptionVisible: true, spacing: 10,
                lineCount: { available in
                    #expect(available == 160)
                    return lines
                }
            )
        }
        #expect(arrangement(lines: 1, width: 150) == .besideTitle)
        #expect(arrangement(lines: 2) == .besideTitleWrapped)
        #expect(arrangement(lines: 3) == .belowTitle)
        // A value with a line break of its own wraps even though each line fits.
        #expect(arrangement(lines: 2, width: 150) == .besideTitleWrapped)
    }

    @Test func availableWidthFollowsTheTitleWithoutExplanation() {
        #expect(ConfigurableRowLayout.availableValueWidth(rowWidth: 340, titleWidth: 90, isDescriptionVisible: false, spacing: 10) == 240)
        #expect(ConfigurableRowLayout.availableValueWidth(rowWidth: 340, titleWidth: 300, isDescriptionVisible: false, spacing: 10) == 160)
        #expect(ConfigurableRowLayout.availableValueWidth(rowWidth: 340, titleWidth: 90, isDescriptionVisible: true, spacing: 10) == 160)
    }
}
