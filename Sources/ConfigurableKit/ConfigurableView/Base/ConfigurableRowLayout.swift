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
    /// Beside the title when the value fits there without being cut off,
    /// otherwise on its own line under the title, using the full row width.
    /// Decided again whenever the row width or the content size changes
    /// (rotation, folding, Dynamic Type, a new value).
    case automatic
    /// Always beside the title, as in earlier versions.
    case trailing
    /// Always on its own line under the title.
    case belowTitle
}

public enum ConfigurableRowLayout {
    /// Decides whether a value of `valueWidth` points should move under the title
    /// of a row that is `rowWidth` points wide.
    ///
    /// Beside the title, the value may use at most half of the row while an
    /// explanation is shown, so the explanation never ends up in a narrow column.
    /// Without an explanation, the value may use everything the title does not
    /// need, but no less than half of the row.
    public static func prefersValueBelowTitle(
        rowWidth: CGFloat,
        valueWidth: CGFloat,
        titleWidth: CGFloat,
        isDescriptionVisible: Bool,
        spacing: CGFloat
    ) -> Bool {
        guard rowWidth > 0, valueWidth > 0 else { return false }
        let half = rowWidth / 2
        let reserved = isDescriptionVisible ? half : min(max(titleWidth, 0), half)
        let available = rowWidth - spacing - reserved
        return valueWidth > available + 0.5
    }
}
