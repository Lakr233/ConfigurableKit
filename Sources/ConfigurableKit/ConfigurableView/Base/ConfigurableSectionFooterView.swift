//
//  ConfigurableSectionFooterView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 1/28/25.
//

import UIKit

open class ConfigurableSectionFooterView: ConfigurableView {
    override open func commitInit() {
        super.commitInit()
        iconView.removeFromSuperview()
        iconContainer.removeFromSuperview()
        contentContainer.removeFromSuperview()
        descriptionLabel.removeFromSuperview()
        contentView.removeFromSuperview()
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
        titleLabel.numberOfLines = 0
        alpha = 0.5
    }

    @discardableResult
    open func with(footer: String) -> Self {
        titleLabel.text = footer
        return self
    }

    override open func configure(icon _: UIImage?) {
        fatalError()
    }

    override open func configure(title _: String) {
        fatalError("Use with(header: String) instead.")
    }

    override open func configure(description _: String) {
        fatalError()
    }
}
