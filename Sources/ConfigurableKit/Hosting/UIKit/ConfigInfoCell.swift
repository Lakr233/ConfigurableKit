//
//  ConfigInfoCell.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import UIKit

final class ConfigInfoCell: UITableViewCell {
    static let reuseIdentifier = "ConfigInfoCell"

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with descriptor: ConfigInfoElement) {
        var configuration = defaultContentConfiguration()
        configuration.text = descriptor.text
        configuration.textProperties.numberOfLines = 0
        configuration.textProperties.color = descriptor.style == .footer ? .secondaryLabel : .label

        if let symbol = descriptor.iconSystemName {
            configuration.image = UIImage(systemName: symbol)
            configuration.imageProperties.tintColor = .secondaryLabel
        }

        switch descriptor.style {
        case .footer:
            configuration.textProperties.font = .preferredFont(forTextStyle: .footnote)
        case .inline:
            configuration.textProperties.font = .preferredFont(forTextStyle: .body)
        }

        contentConfiguration = configuration
    }
}
