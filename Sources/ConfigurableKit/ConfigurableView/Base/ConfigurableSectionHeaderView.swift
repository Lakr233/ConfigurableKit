//
//  ConfigurableSectionHeaderView.swift
//  ConfigurableKit
//
//  Created by 秋星桥 on 1/28/25.
//

import UIKit

open class ConfigurableSectionHeaderView: ConfigurableView {
    override open func commitInit() {
        super.commitInit()
        contentContainer.removeFromSuperview()
        iconContainer.removeFromSuperview()
        iconView.removeFromSuperview()
        titleLabel.font = .preferredFont(forTextStyle: .footnote)
    }

    @discardableResult
    open func with(header: String) -> Self {
        titleLabel.text = header
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
