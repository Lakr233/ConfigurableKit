//
//  ConfigActionCell.swift
//  ConfigurableKit
//
//  Created by GPT-5 Codex on 2025/11/10.
//

import UIKit

final class ConfigActionCell: UITableViewCell {
    static let reuseIdentifier = "ConfigActionCell"

    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var defaultAccessoryType: UITableViewCell.AccessoryType = .disclosureIndicator

    override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = defaultAccessoryType
        selectionStyle = .default
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicator.stopAnimating()
        accessoryView = nil
        accessoryType = defaultAccessoryType
        isUserInteractionEnabled = true
    }

    func configure(with descriptor: ConfigActionElement) {
        var configuration = defaultContentConfiguration()
        configuration.text = descriptor.title
        configuration.secondaryText = descriptor.subtitle
        configuration.secondaryTextProperties.numberOfLines = 0

        switch descriptor.role {
        case .normal:
            configuration.textProperties.color = .label
        case .primary:
            configuration.textProperties.color = tintColor
        case .destructive:
            configuration.textProperties.color = .systemRed
        }

        if let systemName = descriptor.iconSystemName {
            configuration.image = UIImage(systemName: systemName)
            configuration.imageProperties.tintColor = .secondaryLabel
        }

        contentConfiguration = configuration
        isUserInteractionEnabled = descriptor.isEnabled
        contentView.alpha = descriptor.isEnabled ? 1.0 : 0.4
    }

    func setLoading(_ isLoading: Bool) {
        if isLoading {
            accessoryView = activityIndicator
            accessoryType = .none
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            accessoryView = nil
            accessoryType = defaultAccessoryType
        }
    }
}
