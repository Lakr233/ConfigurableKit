//
//  ConfigurableSectionHeaderView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 1/28/25.
//

import Foundation
#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

open class ConfigurableSectionHeaderView: ConfigurableView {
    override open func commitInit() {
        super.commitInit()
        iconView.removeFromSuperview()
        iconContainer.removeFromSuperview()
        contentContainer.removeFromSuperview()
        descriptionLabel.removeFromSuperview()
        contentView.removeFromSuperview()
        titleLabel.font = .preferredFont(forTextStyle: .footnote).semibold
        #if canImport(UIKit)
            titleLabel.numberOfLines = 0
            titleLabel.textColor = .label
        #elseif canImport(AppKit)
            titleLabel.maximumNumberOfLines = 0
            titleLabel.textColor = .labelColor
        #endif
    }

    @discardableResult
    open func with(header: String.LocalizationValue) -> Self {
        let localized = String(localized: header)
        #if canImport(UIKit)
            titleLabel.text = localized
        #elseif canImport(AppKit)
            titleLabel.stringValue = localized
        #endif
        return self
    }

    @_disfavoredOverload
    @discardableResult
    open func with(header: String) -> Self {
        with(header: String.LocalizationValue(header))
    }

    @discardableResult
    open func with(rawHeader: String) -> Self {
        #if canImport(UIKit)
            titleLabel.text = rawHeader
        #elseif canImport(AppKit)
            titleLabel.stringValue = rawHeader
        #endif
        return self
    }

    override open func configure(icon _: CKImage?) {
        fatalError()
    }

    override open func configure(title _: String.LocalizationValue) {
        fatalError("Use with(header: String.LocalizationValue) instead.")
    }

    override open func configure(description _: String.LocalizationValue) {
        fatalError()
    }
}
