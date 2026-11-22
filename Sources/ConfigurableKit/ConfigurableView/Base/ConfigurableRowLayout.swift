//
//  ConfigurableRowLayout.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2026/11/21.
//

import Foundation

/// How a row shows its grey explanation (the `explain` text of a
/// `ConfigurableObject`, or `configure(description:)` of a view).
///
/// Settings pages keep `.full`, which is also what you get when nothing is set.
/// Pages that mostly show data, where people scan values rather than read about
/// options, can use `.singleLine` or `.hidden` so more rows fit on screen. A
/// hidden explanation is still read by VoiceOver as the row's hint.
public enum ConfigurableDescriptionStyle: Sendable, Equatable {
    /// The whole explanation, wrapped over as many lines as it needs.
    case full
    /// The first line of the explanation, truncated at the end.
    case singleLine
    /// No explanation.
    case hidden
}

/// Where a row puts its value (the trailing content: a menu button, a link, a
/// value label, a switch).
public enum ConfigurableValuePlacement: Sendable, Equatable {
    /// Beside the title on one line when the value fits there. Otherwise a text
    /// value wraps beside the title over at most
    /// `ConfigurableRowLayout.maximumValueLinesBesideTitle` lines, and only when
    /// it needs more than that it moves to its own line under the title. The
    /// value is aligned to the trailing edge in every case. Decided again
    /// whenever the row width or the content size changes (rotation, folding,
    /// Dynamic Type, a new value).
    case automatic
    /// Always beside the title, as in earlier versions.
    case trailing
    /// Always on its own line under the title, aligned to the trailing edge.
    case belowTitle
}

/// Where a row currently shows its value.
public enum ConfigurableValueArrangement: Sendable, Equatable {
    /// Beside the title, on one line.
    case besideTitle
    /// Beside the title, wrapped over more than one line and aligned to the
    /// trailing edge.
    case besideTitleWrapped
    /// On its own line under the title, aligned to the trailing edge.
    case belowTitle
}

public enum ConfigurableRowLayout {
    /// The most lines a text value may wrap over beside the title before it
    /// moves under the title.
    public static let maximumValueLinesBesideTitle = 2

    /// The width a value may use beside the title of a row that is `rowWidth`
    /// points wide.
    ///
    /// While an explanation is shown, the value may use at most half of the row,
    /// so the explanation never ends up in a narrow column. Without an
    /// explanation, the value may use everything the title does not need, but
    /// no less than half of the row.
    public static func availableValueWidth(
        rowWidth: CGFloat,
        titleWidth: CGFloat,
        isDescriptionVisible: Bool,
        spacing: CGFloat
    ) -> CGFloat {
        let half = rowWidth / 2
        let reserved = isDescriptionVisible ? half : min(max(titleWidth, 0), half)
        return max(rowWidth - spacing - reserved, 0)
    }

    /// Decides where a value of `valueWidth` points (its width on one line)
    /// goes in a row that is `rowWidth` points wide.
    ///
    /// `lineCount` tells how many lines a text value needs when it may use the
    /// given width. Pass `nil` for a value that cannot wrap (a switch, a custom
    /// view): it stays beside the title while it fits on one line.
    public static func valueArrangement(
        rowWidth: CGFloat,
        valueWidth: CGFloat,
        titleWidth: CGFloat,
        isDescriptionVisible: Bool,
        spacing: CGFloat,
        lineCount: ((CGFloat) -> Int)? = nil
    ) -> ConfigurableValueArrangement {
        guard rowWidth > 0, valueWidth > 0 else { return .besideTitle }
        let available = availableValueWidth(
            rowWidth: rowWidth,
            titleWidth: titleWidth,
            isDescriptionVisible: isDescriptionVisible,
            spacing: spacing
        )
        guard let lineCount else {
            return valueWidth > available + 0.5 ? .belowTitle : .besideTitle
        }
        guard available > 0 else { return .belowTitle }
        let lines = lineCount(available)
        if lines <= 1, valueWidth <= available + 0.5 { return .besideTitle }
        if lines <= maximumValueLinesBesideTitle { return .besideTitleWrapped }
        return .belowTitle
    }

    /// Whether a value that cannot wrap moves under the title. Same as
    /// `valueArrangement(...) == .belowTitle` without a line count.
    public static func prefersValueBelowTitle(
        rowWidth: CGFloat,
        valueWidth: CGFloat,
        titleWidth: CGFloat,
        isDescriptionVisible: Bool,
        spacing: CGFloat
    ) -> Bool {
        valueArrangement(
            rowWidth: rowWidth,
            valueWidth: valueWidth,
            titleWidth: titleWidth,
            isDescriptionVisible: isDescriptionVisible,
            spacing: spacing
        ) == .belowTitle
    }
}
