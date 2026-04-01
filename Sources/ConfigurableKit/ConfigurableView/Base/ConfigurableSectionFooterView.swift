//
//  ConfigurableSectionFooterView.swift
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

open class ConfigurableSectionFooterView: ConfigurableView {
    override open func commitInit() {
        super.commitInit()
        iconView.removeFromSuperview()
        iconContainer.removeFromSuperview()
        contentContainer.removeFromSuperview()
        descriptionLabel.removeFromSuperview()
        contentView.removeFromSuperview()
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        #if canImport(UIKit)
            titleLabel.numberOfLines = 0
            titleLabel.textColor = .secondaryLabel
        #elseif canImport(AppKit)
            titleLabel.maximumNumberOfLines = 0
            titleLabel.textColor = .secondaryLabelColor
        #endif
    }

    @discardableResult
    open func with(footer: String.LocalizationValue) -> Self {
        let localized = String(localized: footer)
        #if canImport(UIKit)
            titleLabel.text = localized
        #elseif canImport(AppKit)
            titleLabel.stringValue = localized
        #endif
        return self
    }

    @_disfavoredOverload
    @discardableResult
    open func with(footer: String) -> Self {
        with(footer: String.LocalizationValue(footer))
    }

    @discardableResult
    open func with(rawFooter: String) -> Self {
        #if canImport(UIKit)
            titleLabel.text = rawFooter
        #elseif canImport(AppKit)
            titleLabel.stringValue = rawFooter
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
