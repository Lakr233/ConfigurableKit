//
//  SeparatorView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 2025/1/4.
//

import Foundation

public protocol ConfigurableSeparatorProtocol: CKView {
    static var defaultHeight: CGFloat { get }
}

public extension ConfigurableSeparatorProtocol {
    static var defaultHeight: CGFloat {
        0.5
    }

    /// ``defaultHeight`` rounded to whole device pixels, never less than one.
    ///
    /// Rows above a separator can have heights that are not whole pixels, so
    /// layout snaps each edge of the separator to the pixel grid. A height that
    /// is not a whole number of pixels (0.5 pt is 1.5 px at 3x) then covers 1 or
    /// 2 px depending on where the row ends, and the 1 px lines look missing
    /// next to the 2 px ones. A whole number of pixels gives every separator the
    /// same thickness.
    static func pixelAlignedHeight(scale: CGFloat) -> CGFloat {
        guard scale > 0, scale.isFinite else { return defaultHeight }
        let pixels = max(1, (defaultHeight * scale).rounded())
        return pixels / scale
    }
}

open class SeparatorView: CKView, ConfigurableSeparatorProtocol {
    public static let color: CKColor = .gray.withAlphaComponent(0.1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        #if canImport(UIKit)
            backgroundColor = Self.color
        #elseif canImport(AppKit)
            wantsLayer = true
            layer?.backgroundColor = Self.color.cgColor
        #endif
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError()
    }
}
